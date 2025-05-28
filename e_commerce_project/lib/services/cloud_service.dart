import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

 
  static Future<void> listModels() async {
    final url = 'https://generativelanguage.googleapis.com/v1/models?key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    print('Desteklenen modeller: ${response.body}');
  }

  static String get _endpoint =>
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  static Future<String?> askQuestion(String question) async {
    final prompt = "Bir e-ticaret asistanı olarak kullanıcıdan gelen soruya kısa ve anlaşılır şekilde cevap ver: $question";
    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('Gemini API yanıtı: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    } else {
      print('Gemini API error: ${response.body}');
      return null;
    }
  }
}