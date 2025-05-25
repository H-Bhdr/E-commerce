import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudAIService {
  static const String _apiKey = 'AIzaSyADiOuK4alaJkALTM9t3ukSTp3lHvKcA10'; // Web için doğrudan yazıldı
  static String get _endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey';

  // Kullanıcıya ürün önerisi almak için fonksiyon
  static Future<String?> getProductRecommendation(String userPrompt) async {
    final body = {
      "contents": [
        {
          "parts": [
            {"text": userPrompt},
          ],
        },
      ],
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Gemini API'nın response formatına göre ayarlayın
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    } else {
      print('Gemini API error: ${response.body}');
      return null;
    }
  }
}
