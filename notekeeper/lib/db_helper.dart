import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  /// Create the required table
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE data(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        desc TEXT,
        createdAt TEXT
      )
    """);
  }

  /// Initialize the database
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "database_name.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  /// Create new data entry
  static Future<int> createData(String title, String? desc) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'desc': desc,
      'createdAt': DateTime.now().toString(),
    };

    final id = await db.insert(
      'data',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );

    return id;
  }

  /// Get all data
  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('data', orderBy: 'id');
  }

  /// Get a single item by ID
  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();
    return db.query(
      'data',
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
  }

  /// Update a note by ID
  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'desc': desc,
      'createdAt': DateTime.now().toString(), // Optionally rename this to 'updatedAt'
    };
    return await db.update(
      'data',
      data,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Delete a note by ID
  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete(
        'data',
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting data: $e");
    }
  }
}
