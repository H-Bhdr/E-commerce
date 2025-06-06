class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  final String? category;
  final double? oldPrice; // <-- eklendi
  final String? firestoreId; // Firestore doküman ID'si

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    this.category,
    this.oldPrice, // <-- eklendi
    this.firestoreId,
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

  static Product fromFirestore(Map<String, dynamic> data, {String? firestoreId}) {
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
      firestoreId: firestoreId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'image': image,
      'category': category,
      if (oldPrice != null) 'oldPrice': oldPrice, // <-- eklendi
    };
  }

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? image,
    String? category,
    double? oldPrice,
    String? firestoreId,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      oldPrice: oldPrice ?? this.oldPrice,
      firestoreId: firestoreId ?? this.firestoreId,
    );
  }
}
