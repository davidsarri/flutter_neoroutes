import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  static final String _apiKey = dotenv.env['CHATGPT_API_KEY'] ?? '';
  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<String> fetchResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "Ets un assistent útil."},
          {"role": "user", "content": prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("Error en la resposta de ChatGPT: ${response.body}");
    }
  }
}
