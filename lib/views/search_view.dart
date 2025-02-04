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
  String _selectedMode = "walking"; // Mode per defecte: a peu

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
              value: _selectedMode,
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
                  _selectedMode = value!;
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
                        travelMode: _selectedMode,
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
