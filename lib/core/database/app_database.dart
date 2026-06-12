import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _databaseName = 'inventory.db';
  static const _databaseVersion = 1;

  Future<Database> open() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/$_databaseName';

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            barcode TEXT NOT NULL,
            name TEXT NOT NULL,
            batch TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            expiry_date TEXT NOT NULL,
            UNIQUE(barcode, batch)
          )
        ''');
      },
    );
  }
}
