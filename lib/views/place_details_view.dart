import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/controllers/main_controller.dart';
import 'package:neoroutes/views/route_map_view.dart';
import 'package:provider/provider.dart';

class PlaceDetailView extends StatelessWidget {
  final Map<String, dynamic> place;
  final LatLng? userLocation;
  final String travelMode;
  final String apiKey = "LA_TEVA_API_KEY"; // Substitueix amb la teva API Key

  const PlaceDetailView(
      {super.key,
      required this.place,
      required this.userLocation,
      required this.travelMode});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainController>(context);
    double distanciaEnMetres =
        controller.distanciaEnMetres(place["lat"], place["lng"], userLocation!);
    String distanciaEnMetresText = distanciaEnMetres.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: Text(place["name"])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (place["photos"] != null && place["photos"].isNotEmpty)
              const SizedBox(height: 16),
            Text(
              place["name"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              place["address"],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            place["open_now"] != null
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Obert ara: ${place["open_now"] == true ? "Sí" : "No"}",
                        style: TextStyle(
                          color: place["open_now"] == true
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            place["photos"] != null && place["photos"].isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: place["photos"].length,
                        itemBuilder: (context, index) {
                          String photoReference =
                              place["photos"][index]["photo_reference"];
                          String photoUrl =
                              controller.getImageUrl(photoReference);

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photoUrl,
                                height: 200,
                                width: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 8),
            if (place["rating"] != null && place["rating"] != 0.0)
              Row(
                children: [
                  Text("Valoració: ${place["rating"]}"),
                  const SizedBox(width: 5),
                  const SizedBox(height: 16),
                ],
              ),
            if (place["description"] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place["description"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            Text(
              "Distància: $distanciaEnMetresText metres",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (userLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Ubicació de l'usuari no disponible")),
                    );
                    return;
                  }

                  // Obrim la pantalla del mapa
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteMapView(
                          userLat: userLocation!.latitude,
                          userLng: userLocation!.longitude,
                          placeLat: place['lat'],
                          placeLng: place['lng'],
                          travelMode: travelMode),
                    ),
                  );
                },
                icon: const Icon(Icons.directions),
                label: const Text("Mostra la ruta"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
