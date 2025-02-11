import 'package:flutter/material.dart';
import 'package:neoroutes/controllers/main_controller.dart';
import 'package:neoroutes/views/main_view.dart';
import 'package:neoroutes/widgets/build_dropdown_widget.dart';
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
  String _selectedOrderMode = "proximity";
  String _selectedSearchMode = "google";

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
              decoration: const InputDecoration(
                labelText: "Cerca un lloc",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            buildDropdownWidget(
              label: "Selecciona el tipus de ruta",
              value: _selectedRouteMode,
              items: const [
                DropdownMenuItem(value: "walking", child: Text("A peu")),
                DropdownMenuItem(value: "driving", child: Text("Conduint")),
              ],
              onChanged: (value) => setState(() => _selectedRouteMode = value),
            ),
            buildDropdownWidget(
              label: "Selecciona si vols tots els locals o només els oberts",
              value: _selectedOpenMode,
              items: const [
                DropdownMenuItem(
                    value: "onlyOpen", child: Text("Només oberts")),
                DropdownMenuItem(value: "all", child: Text("Tots")),
              ],
              onChanged: (value) => setState(() => _selectedOpenMode = value),
            ),
            buildDropdownWidget(
              label: "Selecciona com vols ordenar els resultats",
              value: _selectedOrderMode,
              items: const [
                DropdownMenuItem(value: "proximity", child: Text("Proximitat")),
                DropdownMenuItem(value: "rating", child: Text("Puntuació")),
              ],
              onChanged: (value) => setState(() => _selectedOrderMode = value),
            ),
            buildDropdownWidget(
              label: "Selecciona el mode de cerca",
              value: _selectedSearchMode,
              items: const [
                DropdownMenuItem(value: "google", child: Text("Google Maps")),
                DropdownMenuItem(value: "chatGpt", child: Text("Chat GPT")),
              ],
              onChanged: (value) => setState(() => _selectedSearchMode = value),
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
                          orderMode: _selectedOrderMode,
                          searchMode: _selectedSearchMode),
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
