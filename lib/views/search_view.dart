import 'package:flutter/material.dart';
import 'package:neoroutes/controllers/main_controller.dart';
import 'package:neoroutes/views/main_view.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRouteMode = "walking";
  String _selectedOpenMode = "onlyOpen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cerca llocs")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Cerca un lloc",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown per escollir el tipus de ruta
            DropdownButtonFormField<String>(
              value: _selectedRouteMode,
              decoration: const InputDecoration(
                labelText: "Selecciona el tipus de ruta",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "walking", child: Text("A peu")),
                DropdownMenuItem(value: "driving", child: Text("Conduint")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRouteMode = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedOpenMode,
              decoration: const InputDecoration(
                labelText:
                    "Selecciona si vols tots els locals o nomes els obers",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: "onlyOpen", child: Text("només oberts")),
                DropdownMenuItem(value: "all", child: Text("tots")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedOpenMode = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value:
                          Provider.of<MainController>(context, listen: false),
                      child: MainView(
                        searchQuery: _searchController.text,
                        travelMode: _selectedRouteMode,
                        openMode: _selectedOpenMode,
                      ),
                    ),
                  ),
                );
              },
              child: const Text("Cercar"),
            ),
          ],
        ),
      ),
    );
  }
}
