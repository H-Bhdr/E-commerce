import 'dart:convert';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:http/http.dart' as http;
import 'package:e_commerce_project/data/local/local_db.dart';
import 'package:e_commerce_project/services/connectivity_service.dart';

final LocalDatabase _localDb = LocalDatabase();
final ConnectivityService _connectivityService = ConnectivityService();

Future<List<Product>> fetchProducts() async {
  final isConnected = await _connectivityService.isConnected();
  
  if (isConnected) {
    try {
      final response = await http.get(Uri.parse(
        'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products',
      ));

      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      final jsonData = json.decode(response.body);
      final List<Product> products = [];
      final Set<String> seenKeys = {}; // id+title ile tekrarları engelle

      for (var doc in jsonData['documents']) {
        final data = doc['fields'];
        final firestoreId = doc['name']?.split('/')?.last;
        final product = Product.fromFirestore(data, firestoreId: firestoreId);
        final uniqueKey = '${product.id}_${product.title}';
        if (!seenKeys.contains(uniqueKey)) {
          products.add(product);
          seenKeys.add(uniqueKey);
          // Save to local database
          await _localDb.insertProduct(product);
        }
      }

      return products;
    } catch (e) {
      // Eğer online fetch başarısız olursa, localden çek
      return await _localDb.getAllProducts();
    }
  } else {
    // Eğer offline, localden çek
    final allProducts = await _localDb.getAllProducts();
    // Tekrar eden ürünleri id+title ile sil
    final Map<String, Product> uniqueProducts = {};
    for (final product in allProducts) {
      final uniqueKey = '${product.id}_${product.title}';
      uniqueProducts[uniqueKey] = product;
    }
    return uniqueProducts.values.toList();
  }
}

Future<Product?> fetchProduct(String documentId) async {
  final isConnected = await _connectivityService.isConnected();
  
  if (isConnected) {
    try {
      final url =
          'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products/$documentId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final doc = json.decode(response.body);
        final data = doc['fields'];
        final firestoreId = doc['name']?.split('/')?.last;
        final product = Product.fromFirestore(data, firestoreId: firestoreId);
        // Save to local database
        await _localDb.insertProduct(product);
        return product;
      }
    } catch (e) {
      // If online fetch fails, try to get from local database
      final products = await _localDb.getAllProducts();
      return products.firstWhere((p) => p.id.toString() == documentId);
    }
  } else {
    // If offline, get from local database
    final products = await _localDb.getAllProducts();
    return products.firstWhere((p) => p.id.toString() == documentId);
  }
  return null;
}

Future<bool> addProduct(Product product) async {
  final isConnected = await _connectivityService.isConnected();
  
  // Always save to local database first
  await _localDb.insertProduct(product); // <-- BURADA KAYIT YAPILIYOR
  
  if (isConnected) {
    try {
      final url =
          'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products';
      final body = jsonEncode({"fields": product.toFirestore()});
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  return true; // Return true if saved to local database
}

Future<bool> updateProduct(String documentId, Product product) async {
  final isConnected = await _connectivityService.isConnected();
  
  // Always update local database first
  await _localDb.insertProduct(product); // <-- BURADA KAYIT YAPILIYOR
  
  if (isConnected) {
    try {
      final url =
          'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products/$documentId?updateMask.fieldPaths=id&updateMask.fieldPaths=title&updateMask.fieldPaths=price&updateMask.fieldPaths=description&updateMask.fieldPaths=image&updateMask.fieldPaths=category';
      final body = jsonEncode({"fields": product.toFirestore()});
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  return true; // Return true if updated in local database
}

Future<bool> deleteProduct(String documentId) async {
  final isConnected = await _connectivityService.isConnected();
  
  // Always delete from local database first
  await _localDb.deleteProduct(int.parse(documentId));
  
  if (isConnected) {
    try {
      final url =
          'https://firestore.googleapis.com/v1/projects/e-commerce-firebase-6da6d/databases/(default)/documents/products/$documentId';
      final response = await http.delete(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  return true; // Return true if deleted from local database
 }
