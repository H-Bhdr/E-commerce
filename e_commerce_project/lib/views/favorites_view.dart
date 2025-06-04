import 'package:flutter/material.dart';
import 'package:e_commerce_project/data/local/local_db.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import '../services/favorites_share_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final LocalDatabase _localDb = LocalDatabase();
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _autoFetchFavoritesFromNetwork();
    // Favori paylaşım isteği geldiğinde kullanıcıya sor
    FavoritesShareService.onReceiveFavoritesRequest = (favoritesJson) async {
      final accept = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Favori Paylaşım İsteği'),
          content: Text('Bir cihaz size favori ürünlerini göndermek istiyor. Kabul ediyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Reddet'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Kabul Et'),
            ),
          ],
        ),
      ) ?? false;
      if (accept) {
        // Favoriler eklendikten sonra sayfayı yenile
        await _loadFavorites();
      }
      return accept;
    };
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final products = await _localDb.getFavoriteProducts();
    setState(() {
      _favoriteProducts = products;
      _isLoading = false;
    });
  }

  Future<void> _autoFetchFavoritesFromNetwork() async {
    // Hem 192.168.1.x hem de 10.0.2.x gibi yaygın aralıkları tarar
    final List<String> possibleIps = [
      for (int i = 2; i < 255; i++) '192.168.1.$i',
      for (int i = 2; i < 255; i++) '10.0.2.$i',
    ];
    for (final ip in possibleIps) {
      try {
        final response = await http.get(Uri.parse('http://$ip:8080/favorites')).timeout(const Duration(milliseconds: 700));
        if (response.statusCode == 200) {
          final List<dynamic> favoritesJson = jsonDecode(response.body);
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
            await _localDb.addToFavorites(product.id);
          }
          _loadFavorites();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ağdan favoriler otomatik alındı (${favoritesJson.length} ürün)')),
          );
          break;
        }
      } catch (_) {}
    }
  }

  Future<void> _removeFromFavorites(int productId) async {
    await _localDb.removeFromFavorites(productId);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorilerim'),
        actions: [
          IconButton(
            icon: Icon(Icons.wifi),
            tooltip: 'Favorileri Paylaş (WiFi Sunucu)',
            onPressed: () async {
              final service = FavoritesShareService();
              await service.startServer();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Paylaşım sunucusu başlatıldı: http://localhost:8080/favorites')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Favorileri Al (WiFi)',
            onPressed: () async {
              final ipController = TextEditingController();
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Sunucu IP adresini girin'),
                  content: TextField(
                    controller: ipController,
                    decoration: InputDecoration(hintText: 'örn. 192.168.1.10'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, ipController.text),
                      child: Text('Al'),
                    ),
                  ],
                ),
              );
              if (result != null && result.isNotEmpty) {
                try {
                  final response = await http.get(Uri.parse('http://$result:8080/favorites'));
                  if (response.statusCode == 200) {
                    final List<dynamic> favorites = jsonDecode(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Favoriler başarıyla alındı (${favorites.length} ürün)')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Favoriler alınamadı: ${response.statusCode}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bağlantı hatası: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.send),
            tooltip: 'Favorileri Ağdaki Cihaza Gönder',
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              scaffold.showSnackBar(
                SnackBar(content: Text('Ağ taranıyor, lütfen bekleyin...'), duration: Duration(minutes: 1)),
              );
              // Önce IP aralığını tara, 10.0.2.2'yi ilk sırada deneme
              String? foundIp;
              final List<String> possibleIps = [
                for (int i = 2; i < 255; i++) '192.168.1.$i',
                for (int i = 2; i < 255; i++) '10.0.2.$i',
                '10.0.2.2', // En sona ekle
              ];
              for (final ip in possibleIps) {
                try {
                  final response = await http.get(Uri.parse('http://$ip:8080/favorites')).timeout(const Duration(milliseconds: 200));
                  if (response.statusCode == 200) {
                    foundIp = ip;
                    break;
                  }
                } catch (_) {}
              }
              scaffold.hideCurrentSnackBar();
              if (foundIp == null) {
                scaffold.showSnackBar(
                  SnackBar(content: Text('Ağda başka cihaz bulunamadı.')),
                );
                return;
              }
              final accept = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Favorileri Gönder'),
                  content: Text('Bulunan cihaza favorilerinizi göndermek istiyor musunuz? ($foundIp)'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Gönder'),
                    ),
                  ],
                ),
              );
              if (accept != true) return;
              final favorites = _favoriteProducts.map((e) => e.toJson()).toList();
              try {
                final response = await http.post(
                  Uri.parse('http://$foundIp:8080/receive_favorites'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(favorites),
                );
                if (response.statusCode == 200) {
                  scaffold.showSnackBar(
                    SnackBar(content: Text('Favoriler başarıyla gönderildi ($foundIp)')),
                  );
                } else {
                  scaffold.showSnackBar(
                    SnackBar(content: Text('Gönderim başarısız: ${response.statusCode}')),
                  );
                }
              } catch (e) {
                scaffold.showSnackBar(
                  SnackBar(content: Text('Gönderim hatası: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favoriteProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz favori ürününüz yok',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = _favoriteProducts[index];
                    return Dismissible(
                      key: Key(product.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _removeFromFavorites(product.id);
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          title: Text(
                            product.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${product.price.toStringAsFixed(2)} ₺',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFromFavorites(product.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
