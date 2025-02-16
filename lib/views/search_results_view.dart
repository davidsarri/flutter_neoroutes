import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/controllers/main_controller.dart';
import 'package:neoroutes/views/place_details_view.dart';
import 'package:neoroutes/widgets/stars_rating_widget.dart';
import 'package:provider/provider.dart';

class SearchResultsView extends StatefulWidget {
  final String searchQuery;
  final String travelMode;
  final String openMode;
  final String orderMode;
  final String searchMode;

  const SearchResultsView({
    super.key,
    required this.searchQuery,
    required this.travelMode,
    required this.openMode,
    required this.orderMode,
    required this.searchMode,
  });

  @override
  State<SearchResultsView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchResultsView> {
  late Future<void> _searchFuture;
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<MainController>(context, listen: false);
    _searchFuture = controller.searchPlaces(
      widget.searchQuery,
      widget.travelMode,
      widget.openMode,
      widget.orderMode,
      widget.searchMode,
    );
    if (controller.userLocation != null) {
      userLocation = controller.userLocation;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          userLocation = controller.userLocation;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("NeoRoutes")),
      body: FutureBuilder(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (controller.places.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No s'han trobat resultats amb els filtres escollits.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.places.length,
            itemBuilder: (context, index) {
              var place = controller.places[index];

              return GestureDetector(
                onTap: () async {
                  if (controller.userLocation == null) {
                    await controller.getUserLocation();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailView(
                        place: place,
                        userLocation: controller.userLocation,
                        travelMode: widget.travelMode,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place["name"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          place["address"],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (place["open_now"] != null) ...[
                          Text(
                            "Obert ara: ${place["open_now"] == true ? "Sí" : "No"}",
                            style: TextStyle(
                              color: place["open_now"] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                        Row(
                          children: [
                            if (place["rating"] != 0.0)
                              Text("${place["rating"] ?? "No rating"}"),
                            const SizedBox(width: 5),
                            if (place["rating"] != 0.0)
                              starsRatingWidget(place["rating"]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
