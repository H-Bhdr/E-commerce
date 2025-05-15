import 'package:flutter/material.dart';
import 'package:e_commerce_project/models/porductModel.dart';
import 'package:e_commerce_project/services/productServices.dart';

class AddProductPage extends StatefulWidget {
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
      appBar: AppBar(title: Text('Ürün Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'ID giriniz' : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Başlık'),
                validator: (v) => v == null || v.isEmpty ? 'Başlık giriniz' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Fiyat giriniz' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Açıklama'),
                validator: (v) => v == null || v.isEmpty ? 'Açıklama giriniz' : null,
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Görsel URL'),
                validator: (v) => v == null || v.isEmpty ? 'Görsel URL giriniz' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Kategori (isteğe bağlı)'),
              ),
              SizedBox(height: 20),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Ürün Ekle'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
