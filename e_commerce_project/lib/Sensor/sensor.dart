import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_project/models/porductModel.dart';

class ShakeProductRecommender {
  final List<Product> products;
  final BuildContext context;
  final double shakeThreshold;
  final int minShakeDelayMs;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  int _lastShakeTime = 0;
  bool _dialogOpen = false;

  ShakeProductRecommender({
    required this.products,
    required this.context,
    this.shakeThreshold = 18.0, 
    this.minShakeDelayMs = 1200,
  });

  void startListening() {
    _accelSub = accelerometerEvents.listen(_onAccelerometerEvent);
  }

  void stopListening() {
    _accelSub?.cancel();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    int now = DateTime.now().millisecondsSinceEpoch;
    // Debug için log ekle
    print('Acceleration: $acceleration');
    if (acceleration > shakeThreshold &&
        now - _lastShakeTime > minShakeDelayMs &&
        products.isNotEmpty &&
        !_dialogOpen) {
      print('Shake detected! Showing product dialog.');
      _lastShakeTime = now;
      _showRandomProductDialog();
    }
  }

  void _showRandomProductDialog() {
    if (_dialogOpen) return; 
    _dialogOpen = true;
    final random = Random();
    final product = products[random.nextInt(products.length)];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Sizin için önerdiğimiz ürün'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(product.image, height: 120, fit: BoxFit.contain),
                SizedBox(height: 12),
                Text(
                  product.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '${product.price.toStringAsFixed(2)} ₺',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _dialogOpen = false;
                },
                child: Text('Kapat'),
              ),
            ],
          ),
    ).then((_) {
      _dialogOpen = false;
    });
  }

  
  void debugShowRandomProduct() {
    _showRandomProductDialog();
  }
}
