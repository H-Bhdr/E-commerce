class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  final String? category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    this.category,
  });

  Map<String, dynamic> toFirestore() {
    return {
      "id": {"integerValue": id.toString()},
      "title": {"stringValue": title},
      "price": {"doubleValue": price},
      "description": {"stringValue": description},
      "image": {"stringValue": image},
      if (category != null) "category": {"stringValue": category},
    };
  }

  static Product fromFirestore(Map<String, dynamic> data) {
    return Product(
      id: int.tryParse(data['id']?['integerValue']?.toString() ?? '') ?? 0,
      title: data['title']?['stringValue'] ?? '',
      price: double.tryParse(
              data['price']?['doubleValue']?.toString() ??
              data['price']?['integerValue']?.toString() ??
              '0') ??
          0.0,
      description: data['description']?['stringValue'] ?? '',
      image: data['image']?['stringValue'] ?? '',
      category: data['category']?['stringValue'],
    );
  }
}
