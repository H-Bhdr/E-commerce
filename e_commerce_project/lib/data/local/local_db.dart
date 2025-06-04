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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        title TEXT,
        price REAL,
        firestore_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE product_details(
        product_id INTEGER PRIMARY KEY,
        description TEXT,
        image TEXT,
        category TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites(
        product_id INTEGER PRIMARY KEY,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE products ADD COLUMN firestore_id TEXT');
    }
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'products',
        {
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'firestore_id': product.firestoreId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        'product_details',
        {
          'product_id': product.id,
          'description': product.description,
          'image': product.image,
          'category': product.category,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, pd.description, pd.image, pd.category 
      FROM products p
      LEFT JOIN product_details pd ON p.id = pd.product_id
    ''');
    
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        title: maps[i]['title'],
        price: maps[i]['price'],
        description: maps[i]['description'],
        image: maps[i]['image'],
        category: maps[i]['category'],
        firestoreId: maps[i]['firestore_id'],
      );
    });
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, pd.description, pd.image, pd.category 
      FROM products p
      LEFT JOIN product_details pd ON p.id = pd.product_id
      WHERE p.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      return Product(
        id: maps[0]['id'],
        title: maps[0]['title'],
        price: maps[0]['price'],
        description: maps[0]['description'],
        image: maps[0]['image'],
        category: maps[0]['category'],
        firestoreId: maps[0]['firestore_id'],
      );
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'products',
        {
          'title': product.title,
          'price': product.price,
          'firestore_id': product.firestoreId,
        },
        where: 'id = ?',
        whereArgs: [product.id],
      );

      await txn.update(
        'product_details',
        {
          'description': product.description,
          'image': product.image,
          'category': product.category,
        },
        where: 'product_id = ?',
        whereArgs: [product.id],
      );
    });
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

  // Favorites related methods
  Future<void> addToFavorites(int productId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'product_id': productId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromFavorites(int productId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<bool> isFavorite(int productId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }

  Future<List<Product>> getFavoriteProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, pd.description, pd.image, pd.category 
      FROM products p
      LEFT JOIN product_details pd ON p.id = pd.product_id
      INNER JOIN favorites f ON p.id = f.product_id
    ''');
    
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        title: maps[i]['title'],
        price: maps[i]['price'],
        description: maps[i]['description'],
        image: maps[i]['image'],
        category: maps[i]['category'],
        firestoreId: maps[i]['firestore_id'],
      );
    });
  }
}