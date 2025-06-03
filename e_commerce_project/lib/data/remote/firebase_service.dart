import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  final String projectId = 'e-commerce-firebase-6da6d';

  Future<void> importFakeStoreProducts() async {
    final fakeStoreUrl = Uri.parse('https://fakestoreapi.com/products');
    final firebaseUrl = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/products');

    final response = await http.get(fakeStoreUrl);

    if (response.statusCode == 200) {
      List<dynamic> products = jsonDecode(response.body);

      for (var product in products) {
        final doc = {
          "fields": {
            "id": {"integerValue": product["id"].toString()},
            "title": {"stringValue": product["title"]},
            "price": {"doubleValue": product["price"]},
            "description": {"stringValue": product["description"]},
            "category": {"stringValue": product["category"]},
            "image": {"stringValue": product["image"]},
          }
        };

        final res = await http.post(
          firebaseUrl,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(doc),
        );

        if (res.statusCode == 200) {
          print('Ürün eklendi: ${product["title"]}');
        } else {
          print('Hata oluşmuştur: ${res.body}');
        }
      }
    } else {
      print('FakeStore API isteği başarısız: ${response.statusCode}');
    }
  }
}
