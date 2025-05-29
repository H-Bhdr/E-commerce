import 'package:flutter/material.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:e_commerce_project/services/productServices.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _categoryController = TextEditingController();
  final _idController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageController.dispose();
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
      image: _imageController.text,
      category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
    );

    final success = await addProduct(product);

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ürün eklendi!')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ürün eklenemedi!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
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
                          validator: (v) => v == null || v.isEmpty ? 'ID giriniz' : null,
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
                          validator: (v) => v == null || v.isEmpty ? 'Başlık giriniz' : null,
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
                          validator: (v) => v == null || v.isEmpty ? 'Fiyat giriniz' : null,
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
                          validator: (v) => v == null || v.isEmpty ? 'Açıklama giriniz' : null,
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _imageController,
                          decoration: InputDecoration(
                            labelText: 'Görsel URL',
                            prefixIcon: Icon(Icons.image),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Görsel URL giriniz' : null,
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
                SizedBox(height: 24.0),
                _loading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'ÜRÜN EKLE',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
