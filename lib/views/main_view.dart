import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/controllers/main_controller.dart';
import 'package:neoroutes/controllers/map_controller.dart';
import 'package:neoroutes/views/search_view.dart';
import 'package:neoroutes/widgets/stars_rating_widget.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  final String searchQuery;
  final String travelMode;
  final String openMode;
  final String orderMode;
  final String searchMode;

  const MainView(
      {super.key,
      required this.searchQuery,
      required this.travelMode,
      required this.openMode,
      required this.orderMode,
      required this.searchMode});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainController>(context, listen: false);
    final mapController = Provider.of<MapController>(context, listen: false);
    controller.searchPlaces(
        searchQuery, travelMode, openMode, orderMode, searchMode);

    return Consumer<MainController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("NeoRoutes")),
          body: controller.isLoading == true
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // Google Maps
                    Positioned.fill(
                      child: GoogleMap(
                        onMapCreated: mapController.setMapController,
                        initialCameraPosition: CameraPosition(
                          target: controller.userLocation ??
                              const LatLng(41.3874, 2.1686),
                          zoom: 14,
                        ),
                        markers: mapController.markers,
                        polylines: mapController.getPolylines,
                      ),
                    ),

                    // Botó flotant per obrir la cerca
                    Positioned(
                      bottom: 80,
                      right: 10,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SearchView()),
                          );
                        },
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),

                    // Llista de llocs trobats
                    if (controller.places.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
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
                                        Text(
                                            "${place["rating"] ?? "No rating"}"),
                                        const SizedBox(width: 5),
                                        if (place["rating"] != null)
                                          starsRatingWidget(place["rating"])
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: (place["open_now"] ?? false)
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : const Icon(Icons.close,
                                        color: Colors.red),
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
