import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<List<Map<String, dynamic>>> queryChatGPT(
      String userQuery, String city) async {
    if (_apiKey.isEmpty) {
      debugPrint("Error: API Key de OpenAI no definida.");
      return [];
    }

    final body = jsonEncode({
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
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return _parseResponse(response.bodyBytes);
      } else {
        debugPrint("Error en la resposta de ChatGPT: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error en queryChatGPT: $e");
    }
    return [];
  }

  List<Map<String, dynamic>> _parseResponse(Uint8List responseBodyBytes) {
    try {
      final utf8Decoded = utf8.decode(responseBodyBytes);
      final data = jsonDecode(utf8Decoded);
      String rawText = data['choices'][0]['message']['content']?.trim() ?? '';

      if (rawText.isEmpty ||
          !rawText.startsWith("[") ||
          !rawText.endsWith("]")) {
        debugPrint("Resposta de ChatGPT no és un JSON vàlid: $rawText");
        return [];
      }

      final extractedJson = jsonDecode(rawText);
      if (extractedJson is List) {
        return extractedJson.map((place) => _formatPlace(place)).toList();
      }
    } catch (e) {
      debugPrint("Error analitzant JSON: $e");
    }
    return [];
  }

  Map<String, dynamic> _formatPlace(Map<String, dynamic> place) {
    return {
      "id": "${place["name"]}_${place["lat"]}",
      "name": place["name"] ?? "Sense nom",
      "address": place["address"] ?? "Sense adreça",
      "lat": place["lat"] ?? 0.0,
      "lng": place["lng"] ?? 0.0,
      "rating": 0.0, // No tenim puntuació, posem 0.0 per defecte
      "open_now": null // No tenim informació d'obertura, posem null
    };
  }
}
