import 'package:flutter/material.dart';
import 'package:e_commerce_project/services/productServices.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:e_commerce_project/views/add_product.dart';

import 'package:e_commerce_project/Sensor/sensor.dart';
import 'package:e_commerce_project/data/local/local_db.dart';
import 'package:e_commerce_project/services/cloud_service.dart';
import 'package:e_commerce_project/services/background_service.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  bool _productsLoaded = false;
  ShakeProductRecommender? _shakeRecommender;
  final LocalDatabase _localDb = LocalDatabase();
  Map<int, bool> _favoriteStatus = {};
  double? _testRate;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    // Fiyatlar güncellenince Home'un state'ini tamamen yenile
    CurrencyBackgroundService().onPriceUpdate = (rate, time) {
      if (mounted) {
        // Tüm state'i sıfırla ve yeniden yükle
        setState(() {
          _productsLoaded = false;
          _products = [];
          _favoriteStatus.clear();
        });
        // Favori durumlarını da tekrar yükle
        _loadFavoriteStatus();
      }
    };
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

  final TextEditingController _keywordController = TextEditingController();

  void _showAIRecommendation(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    final products = await fetchProducts();

    if (products.isEmpty) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('AI Ürün Önerisi'),
              content: Text('Ürün bulunamadı.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Kapat'),
                ),
              ],
            ),
      );
      return;
    }

    final keyword = _keywordController.text.trim().toLowerCase();

  
    List<Product> filteredProducts = [];
    if (keyword.isNotEmpty) {
      filteredProducts = products.where((p) =>
        (p.title.toLowerCase().contains(keyword)) ||
        (p.description?.toLowerCase().contains(keyword) ?? false)
      ).toList();
    }

  
    final random = Random();
    List<Product> limitedProducts;
    if (filteredProducts.isNotEmpty) {
      filteredProducts.shuffle(random);
      limitedProducts = filteredProducts.take(5).toList();
    } else {
      final shuffledProducts = List<Product>.from(products)..shuffle(random);
      limitedProducts = shuffledProducts.take(5).toList();
    }

    
    final productListText = limitedProducts
        .map(
          (p) =>
              "${p.title} - ${(p.description?.isNotEmpty == true ? p.description : 'Açıklama yok')}\nGörsel: ${p.image}",
        )
        .join("\n");

    
    final question = '''
Aşağıdaki ürünler arasından bir e-ticaret müşterisine "${_keywordController.text}" ile ilgili en dikkat çekici ürünü seç.
Sadece ürün adı, kısa açıklama ve görsel URL'sini döndür. Format:
Ad: ...
Açıklama: ...
Görsel: ...

Ürünler:
$productListText
''';

    final result = await GeminiService.askQuestion(question);
    Navigator.of(context).pop();

    // Yanıtı ayrıştır
    String? name, desc, imageUrl;
    if (result != null) {
      final nameMatch = RegExp(r'Ad:\s*(.*)').firstMatch(result);
      final descMatch = RegExp(r'Açıklama:\s*(.*)').firstMatch(result);
      final imageMatch = RegExp(r'Görsel:\s*(.*)').firstMatch(result);
      name = nameMatch?.group(1);
      desc = descMatch?.group(1);
      imageUrl = imageMatch?.group(1);
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('AI Ürün Önerisi'),
            content:
                result == null
                    ? Text('Öneri alınamadı.')
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            height: 120,
                            errorBuilder: (_, __, ___) => Icon(Icons.image),
                          ),
                        if (name != null)
                          Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (desc != null) Text(desc),
                      ],
                    ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Kapat'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 24.0,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    labelText: 'Anahtar kelime ile öneri al (örn: yüzük, tişört, ekran...)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.auto_awesome),
                    label: Text('AI ile Ürün Önerisi Al'),
                    onPressed: () => _showAIRecommendation(context),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.trending_up),
                    label: Text('Kuru Test İçin Artır'),
                    onPressed: () async {
                      final service = CurrencyBackgroundService();
                      if (service.lastUsdTryRate == null) {
                        await service.fetchAndUpdate();
                      }
                      service.lastUsdTryRate = (service.lastUsdTryRate ?? 30.0) - 5.0;
                      await service.fetchAndUpdate();
                      // --- Uniq ürünler bırak, tekrar edenleri sil ---
                      final allProducts = await _localDb.getAllProducts();
                      final Set<String> seen = {};
                      for (final product in allProducts) {
                        final key = '${product.id}_${product.title}';
                        if (seen.contains(key)) {
                          await _localDb.deleteProduct(product.id);
                        } else {
                          seen.add(key);
                        }
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kur test için artırıldı ve tekrar eden ürünler silindi!')),
                        );
                        setState(() {
                          _productsLoaded = false;
                          _products = [];
                          _favoriteStatus.clear();
                        });
                        await _loadFavoriteStatus();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
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
                      return Stack(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Ürün detayına yönlendirme eklenebilir
                            },
                            child: Container(
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
                                      product.image,
                                      height: 300,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
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
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }
}