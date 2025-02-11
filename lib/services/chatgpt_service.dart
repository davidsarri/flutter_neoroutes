import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<List<Map<String, dynamic>>> queryChatGPT(
      String userQuery, String city) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "Ets un assistent de viatges. Retorna només un JSON amb llocs a visitar."
            },
            {
              "role": "user",
              "content":
                  "Estic a $city. $userQuery. Torna només un JSON amb un array de llocs en aquest format: "
                      "[{\"name\": \"Nom del lloc\", \"address\": \"Adreça\", \"lat\": 00.00, \"lng\": 00.00}]. "
                      "No afegeixis cap altre text."
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final utf8Decoded = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8Decoded);
        String rawText = data['choices'][0]['message']['content'];

        // **Intentar parsejar el JSON retornat**
        List<Map<String, dynamic>> extractedPlaces =
            _extractPlacesFromResponse(rawText);

        // **Transformar els resultats per tenir la mateixa estructura que Google Maps**
        return extractedPlaces.map((place) {
          return {
            "id": place["name"] + place["lat"].toString(), // Generar un ID únic
            "name": place["name"],
            "address": place["address"],
            "lat": place["lat"],
            "lng": place["lng"],
            "rating":
                0.0, // ChatGPT no retorna puntuació, posem 0.0 per defecte
            "open_now": null // No tenim informació d'obertura, posem null
          };
        }).toList();
      } else {
        throw Exception("Error en la resposta de ChatGPT: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error en queryChatGPT: $e");
      return [];
    }
  }

  List<Map<String, dynamic>> _extractPlacesFromResponse(String responseText) {
    try {
      // **Eliminem caràcters innecessaris i ens assegurem que és un JSON vàlid**
      responseText = responseText.trim();

      // Verifiquem si la resposta comença i acaba amb [ ] (llista JSON)
      if (!responseText.startsWith("[") || !responseText.endsWith("]")) {
        print("Resposta de ChatGPT no és un JSON vàlid: $responseText");
        return [];
      }

      final extractedJson = jsonDecode(responseText);
      if (extractedJson is List) {
        return extractedJson.cast<Map<String, dynamic>>();
      } else {
        print("Resposta JSON no és una llista: $extractedJson");
      }
    } catch (e) {
      print("Error analitzant JSON: $e");
    }
    return [];
  }
}
