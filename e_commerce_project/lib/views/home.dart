import 'package:flutter/material.dart';
import 'package:e_commerce_project/services/productServices.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:e_commerce_project/views/add_product.dart';
import 'package:e_commerce_project/services/cloud_service.dart';

class HomePage extends StatelessWidget {
  void _showAIRecommendation(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    final result = await CloudAIService.getProductRecommendation(
      "Bir e-ticaret müşterisine popüler ürün önerisi ver. Sadece ürün adı ve kısa açıklama döndür.",
    );
    Navigator.of(context).pop(); // loading dialog kapat
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('AI Ürün Önerisi'),
            content: Text(result ?? 'Öneri alınamadı.'),
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.auto_awesome),
                label: Text('AI ile Ürün Önerisi Al'),
                onPressed: () => _showAIRecommendation(context),
              ),
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
                                      product.image,
                                      height: 300, // Yükseklik artırıldı
                                      fit:
                                          BoxFit
                                              .contain, // Sığdırmak için değiştirildi
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height:
                                                    300, // Yükseklik eşitlendi
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
                                    ), // Padding artırıldı
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                  onTap: () {
                                    // Favori butonu aksiyonu
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.favorite_border,
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
          ),
        ],
      ),
    );
  }
}
