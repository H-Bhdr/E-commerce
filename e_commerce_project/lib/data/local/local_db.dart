import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:e_commerce_project/models/porductModel.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  factory LocalDatabase() {
    return _instance;
  }

  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        title TEXT,
        price REAL,
        description TEXT,
        image TEXT,
        category TEXT
      )
    ''');
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'image': product.image,
        'category': product.category,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        title: maps[i]['title'],
        price: maps[i]['price'],
        description: maps[i]['description'],
        image: maps[i]['image'],
        category: maps[i]['category'],
      );
    });
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product(
        id: maps[0]['id'],
        title: maps[0]['title'],
        price: maps[0]['price'],
        description: maps[0]['description'],
        image: maps[0]['image'],
        category: maps[0]['category'],
      );
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      {
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'image': product.image,
        'category': product.category,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllProducts() async {
    final db = await database;
    await db.delete('products');
  }
}
