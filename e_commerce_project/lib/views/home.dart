import 'package:flutter/material.dart';
import 'package:e_commerce_project/services/productServices.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:e_commerce_project/views/add_product.dart';
import 'package:e_commerce_project/Sensor/sensor.dart';
import 'package:e_commerce_project/data/local/local_db.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  bool _productsLoaded = false;
  ShakeProductRecommender? _shakeRecommender;
  final LocalDatabase _localDb = LocalDatabase();
  Map<int, bool> _favoriteStatus = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    for (var product in _products) {
      _favoriteStatus[product.id] = await _localDb.isFavorite(product.id);
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleFavorite(int productId) async {
    final isFavorite = await _localDb.isFavorite(productId);
    if (isFavorite) {
      await _localDb.removeFromFavorites(productId);
    } else {
      await _localDb.addToFavorites(productId);
    }
    setState(() {
      _favoriteStatus[productId] = !isFavorite;
    });
  }

  @override
  void dispose() {
    _shakeRecommender?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Ürün bulunamadı.'));
          } else {
            final products = snapshot.data!;
            // Sensör dinleyicisini sadece bir kez başlat
            if (!_productsLoaded) {
              _products = products;
              _shakeRecommender = ShakeProductRecommender(
                products: _products,
                context: context,
              );
              _shakeRecommender!.startListening();
              _productsLoaded = true;
              _loadFavoriteStatus();
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Ürün detayına yönlendirme eklenebilir
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.06),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                (product.image.startsWith('http://') ||
                                        product.image.startsWith('https://'))
                                    ? product.image
                                    : 'https://via.placeholder.com/300x300?text=No+Image',
                                height: 300,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 300,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                      ),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '${product.price.toStringAsFixed(2)} ₺',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 26,
                        bottom: 18,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => _toggleFavorite(product.id),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                _favoriteStatus[product.id] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.redAccent,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
