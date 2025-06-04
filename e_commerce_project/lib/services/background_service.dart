import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_commerce_project/data/local/local_db.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:e_commerce_project/services/productServices.dart';
import 'package:e_commerce_project/services/notification_service.dart';

class CurrencyBackgroundService {
  static final CurrencyBackgroundService _instance = CurrencyBackgroundService._internal();
  factory CurrencyBackgroundService() => _instance;
  CurrencyBackgroundService._internal();

  Timer? _timer;
  double? lastUsdTryRate;
  final LocalDatabase _localDb = LocalDatabase();

  void Function(double rate, DateTime updateTime)? onPriceUpdate;

  void start() {
    _timer?.cancel();
    fetchAndUpdate();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchAndUpdate());
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> fetchAndUpdate() async {
    try {
      final rate = await _fetchUsdTryRate();
      if (rate == null) return;
      if (lastUsdTryRate == null || (lastUsdTryRate! - rate).abs() >= 0.01) {
        print('USD/TRY kuru değişti: $lastUsdTryRate → $rate');
        await _updateProductPrices(rate);
        lastUsdTryRate = rate;
      }
    } catch (e) {
      print('Kur güncelleme hatası: $e');
    }
  }

  Future<double?> _fetchUsdTryRate() async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['rates']?['TRY'] as num?)?.toDouble();
    }
    return null;
  }

  Future<void> _updateProductPrices(double usdTryRate) async {
    final products = await _localDb.getAllProducts();
    final favoriteProducts = await _localDb.getFavoriteProducts();
    final favoriteIds = favoriteProducts.map((p) => p.id).toSet();

    for (final product in products) {
      final newPrice = product.price / (lastUsdTryRate ?? usdTryRate) * usdTryRate;
      // Sadece fiyat değiştiyse güncelle
      if (product.price != newPrice) {
        final updatedProduct = product.copyWith(
          price: newPrice,
          oldPrice: product.price, // eski fiyatı ekle
        );
        await _localDb.updateProduct(updatedProduct);
        print('Fiyat güncellendi: \x1b[1m[1m${updatedProduct.title}\x1b[0m | Eski: ${product.price.toStringAsFixed(2)} ₺ | Yeni: ${updatedProduct.price.toStringAsFixed(2)} ₺');
        try {
          if (product.firestoreId != null) {
            await updateProduct(product.firestoreId!, updatedProduct);
          } else {
            print('Firestore ID bulunamadı, güncelleme atlanıyor: ${product.title}');
          }
        } catch (e) {
          print('Backend fiyat güncelleme hatası (${updatedProduct.id}): $e');
        }
        // Favorilerde ise bildirim gönder
        if (favoriteIds.contains(product.id)) {
          NotificationService.broadcastPriceChange(updatedProduct);
        }
      }
    }
  }
}
