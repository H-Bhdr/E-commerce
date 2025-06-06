import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../data/local/local_db.dart';
import '../models/porductModel.dart';

/// Sunucu başlatıp favori ürünleri JSON olarak paylaşır.
class FavoritesShareService {
  HttpServer? _server;

  /// Sunucuyu başlatır ve favori ürünleri paylaşır.
  Future<void> startServer({int port = 8080}) async {
    final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    print('Favori paylaşım sunucusu başlatıldı: http://localhost:$port/favorites');
  }

  /// Sunucuyu durdurur.
  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }

  /// Favori ürünleri JSON olarak döner.
  Future<Response> _router(Request request) async {
    if (request.url.path == 'favorites') {
      final favorites = await LocalDatabase().getFavoriteProducts();
      final jsonList = favorites.map((e) => e.toJson()).toList();
      return Response.ok(jsonEncode(jsonList), headers: {'Content-Type': 'application/json'});
    }
    if (request.url.path == 'receive_favorites' && request.method == 'POST') {
      final body = await request.readAsString();
      final List<dynamic> favoritesJson = jsonDecode(body);
      bool accept = true;
      if (onReceiveFavoritesRequest != null) {
        // UI'dan onay bekle
        accept = await onReceiveFavoritesRequest!(favoritesJson);
      }
      if (!accept) {
        return Response.forbidden('Kullanıcı paylaşımı reddetti');
      }
      for (final fav in favoritesJson) {
        final product = Product(
          id: fav['id'],
          title: fav['title'],
          price: (fav['price'] as num).toDouble(),
          description: fav['description'],
          image: fav['image'],
          category: fav['category'],
          oldPrice: fav['oldPrice'] != null ? (fav['oldPrice'] as num).toDouble() : null,
          firestoreId: fav['firestoreId'],
        );
        await LocalDatabase().addToFavorites(product.id);
      }
      return Response.ok('Favoriler kaydedildi');
    }
    return Response.notFound('Not Found');
  }

  /// Favori paylaşım isteği geldiğinde UI'ya haber vermek için event callback
  static Future<bool> Function(List<dynamic> favorites)? onReceiveFavoritesRequest;
}
