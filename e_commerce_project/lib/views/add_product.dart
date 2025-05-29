import 'package:flutter/material.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:e_commerce_project/services/productServices.dart';
import 'package:e_commerce_project/services/cloud_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aiPromptController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _idController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _aiPromptController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final product = Product(
      id: int.tryParse(_idController.text) ?? 0,
      title: _titleController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      description: _descController.text,
      image: _imageUrlController.text,
      category:
          _categoryController.text.isNotEmpty ? _categoryController.text : null,
    );

    final success = await addProduct(product);

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ürün eklendi!')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ürün eklenemedi!')));
    }
  }

  Future<void> _fillWithAI() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    final question = '''
Bir e-ticaret satıcısı için "${prompt}" anahtar kelimesiyle yeni bir ürün eklemek istiyorum. 
Bana kısa bir ürün adı, açıklaması, örnek bir görsel URL'si, kategori ve tahmini fiyat öner. 
Format:
Ad: ...
Açıklama: ...
Görsel: ...
Kategori: ...
Fiyat: ...
''';

    final result = await GeminiService.askQuestion(question);
    Navigator.of(context).pop();

    if (result != null) {
      final nameMatch = RegExp(r'Ad:\s*(.*)').firstMatch(result);
      final descMatch = RegExp(r'Açıklama:\s*(.*)').firstMatch(result);
      final imageMatch = RegExp(r'Görsel:\s*(.*)').firstMatch(result);
      final categoryMatch = RegExp(r'Kategori:\s*(.*)').firstMatch(result);
      final priceMatch = RegExp(r'Fiyat:\s*([\d.,]+)').firstMatch(result);

      final aiTitle = nameMatch?.group(1) ?? '';
      final aiDesc = descMatch?.group(1) ?? '';
      final aiImage = imageMatch?.group(1) ?? '';
      final aiCategory = categoryMatch?.group(1) ?? '';
      final aiPrice = priceMatch?.group(1)?.replaceAll(',', '.') ?? '';

      // Önizleme dialogu
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('AI Ürün Önerisi Önizlemesi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (aiImage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Image.network(
                      aiImage,
                      height: 120,
                      errorBuilder: (_, __, ___) => Icon(Icons.image),
                    ),
                  ),
                if (aiTitle.isNotEmpty)
                  Text(aiTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                if (aiDesc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(aiDesc),
                  ),
                if (aiCategory.isNotEmpty)
                  Text('Kategori: $aiCategory'),
                if (aiPrice.isNotEmpty)
                  Text('Fiyat: $aiPrice'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Vazgeç
              child: Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _titleController.text = aiTitle;
                  _descController.text = aiDesc;
                  _imageUrlController.text = aiImage;
                  _categoryController.text = aiCategory;
                  _priceController.text = aiPrice;
                });
                Navigator.of(context).pop();
              },
              child: Text('Kabul Et'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI önerisi alınamadı.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ürün Bilgileri',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _idController,
                              decoration: InputDecoration(
                                labelText: 'ID',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'ID giriniz'
                                          : null,
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Başlık',
                                prefixIcon: Icon(Icons.title),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Başlık giriniz'
                                          : null,
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Fiyat',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Fiyat giriniz'
                                          : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ürün Detayları',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _descController,
                              decoration: InputDecoration(
                                labelText: 'Açıklama',
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              maxLines: 3,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Açıklama giriniz'
                                          : null,
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                labelText: 'Görsel URL',
                                prefixIcon: Icon(Icons.image),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Görsel URL giriniz'
                                          : null,
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _categoryController,
                              decoration: InputDecoration(
                                labelText: 'Kategori (isteğe bağlı)',
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        'ÜRÜN EKLE',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
              SizedBox(height: 16.0),
              TextField(
                controller: _aiPromptController,
                decoration: InputDecoration(
                  labelText:
                      'AI ile otomatik doldurmak için anahtar kelime girin',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.auto_awesome),
                  label: Text('AI ile Otomatik Doldur'),
                  onPressed: _fillWithAI,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
