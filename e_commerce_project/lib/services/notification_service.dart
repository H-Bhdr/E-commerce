import 'package:e_commerce_project/models/porductModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final ValueNotifier<Product?> priceChangeNotifier = ValueNotifier<Product?>(null);
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showPriceChangeNotification(Product product) async {
    final oldPrice = product.oldPrice;
    final newPrice = product.price;
    final String body = (oldPrice != null)
        ? 'Eski: ${oldPrice.toStringAsFixed(2)} ₺  Yeni: ${newPrice.toStringAsFixed(2)} ₺'
        : 'Yeni fiyat: ${newPrice.toStringAsFixed(2)} ₺';
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'price_change_channel',
      'Fiyat Değişikliği',
      channelDescription: 'Favori ürün fiyat değişiklikleri',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Favori ürününüzün fiyatı değişti: ${product.title}',
      body,
      platformChannelSpecifics,
    );
  }

  // BroadcastReceiver benzeri bir fonksiyon (örnek, platforma göre özelleştirilebilir)
  static void broadcastPriceChange(Product product) {
    // Notifier'ı tetikle
    priceChangeNotifier.value = product;
    showPriceChangeNotification(product); // <-- native notification
    // Konsola da yazmaya devam et
    print('BİLDİRİM: Favori ürününüzün fiyatı değişti: \x1b[1m${product.title}\x1b[0m → ${product.price.toStringAsFixed(2)} ₺');
    // Gerçek uygulamada burada flutter_local_notifications veya benzeri ile bildirim gösterilebilir.
  }
}