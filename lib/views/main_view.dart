import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/controllers/main_controller.dart';
import 'package:neoroutes/widgets/stars_rating_widget.dart';
import 'package:provider/provider.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("NeoRoutes")),
          body: Stack(
            children: [
              // Google Maps
              Positioned.fill(
                child: GoogleMap(
                  onMapCreated: (mapController) {
                    controller.setMapController(mapController);
                  },
                  initialCameraPosition: CameraPosition(
                    target: controller.userLocation ??
                        const LatLng(41.3874, 2.1686), // Ubicació per defecte
                    zoom: 14,
                  ),
                  markers: controller.markers,
                  polylines: controller.getPolylines,
                ),
              ),

              // Barra de cerca
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: null,
                        decoration: InputDecoration(
                          hintText: "Cerca llocs...",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.blue),
                      onPressed: () {
                        controller.searchPlaces(_searchController.text);
                      },
                    ),
                  ],
                ),
              ),

              // Botó per recentrar el mapa
              Positioned(
                bottom: 80,
                right: 10,
                child: FloatingActionButton(
                  onPressed: controller.centerMap,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),

              // Llista de llocs trobats
              if (controller.places.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 350,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: controller.places.length,
                      itemBuilder: (context, index) {
                        var place = controller.places[index];

                        return ListTile(
                          title: Text(place["name"]),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place["address"]),
                              Row(
                                children: [
                                  Text("${place["rating"] ?? "No rating"}"),
                                  const SizedBox(width: 5),
                                  if (place["rating"] != null)
                                    starsRatingWidget(place["rating"])
                                ],
                              ),
                            ],
                          ),
                          trailing: place["open_now"]
                              ? const Icon(Icons.check, color: Colors.green)
                              : const Icon(Icons.close, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
