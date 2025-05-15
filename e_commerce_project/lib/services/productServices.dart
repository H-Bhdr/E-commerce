import 'dart:convert';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:http/http.dart' as http;

Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse(
    'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products',
  ));

  if (response.statusCode != 200) {
    throw Exception('Failed to load products');
  }

  final jsonData = json.decode(response.body);
  final List<Product> products = [];

  for (var doc in jsonData['documents']) {
    final data = doc['fields'];
    products.add(Product.fromFirestore(data));
  }

  return products;
}

Future<Product?> fetchProduct(String documentId) async {
  final url =
      'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products/$documentId';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final doc = json.decode(response.body);
    final data = doc['fields'];
    return Product.fromFirestore(data);
  } else {
    return null;
  }
}

Future<bool> addProduct(Product product) async {
  final url =
      'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products';
  final body = jsonEncode({"fields": product.toFirestore()});
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );
  return response.statusCode == 200;
}

Future<bool> updateProduct(String documentId, Product product) async {
  final url =
      'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products/$documentId?updateMask.fieldPaths=id&updateMask.fieldPaths=title&updateMask.fieldPaths=price&updateMask.fieldPaths=description&updateMask.fieldPaths=image&updateMask.fieldPaths=category';
  final body = jsonEncode({"fields": product.toFirestore()});
  final response = await http.patch(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );
  return response.statusCode == 200;
}

Future<bool> deleteProduct(String documentId) async {
  final url =
      'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products/$documentId';
  final response = await http.delete(Uri.parse(url));
  return response.statusCode == 200;
}
