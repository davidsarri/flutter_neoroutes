import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String _apiKey = dotenv.env['CHATGPT_API_KEY'] ?? '';
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
        final data = jsonDecode(response.body);
        String rawText = data['choices'][0]['message']['content'];

        // **Intentar parsejar el JSON retornat**
        return _extractPlacesFromResponse(rawText);
      } else {
        throw Exception("Error en la resposta de ChatGPT: ${response.body}");
      }
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> _extractPlacesFromResponse(String responseText) {
    try {
      final extractedJson = jsonDecode(responseText);
      if (extractedJson is List) {
        return extractedJson.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print("Error analitzant JSON: $e");
    }
    return [];
  }
}
