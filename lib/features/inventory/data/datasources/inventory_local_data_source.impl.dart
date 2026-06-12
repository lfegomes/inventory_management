import 'package:sqflite/sqflite.dart';

import 'package:inventory_management/features/inventory/data/models/product_model.dart';
import 'package:inventory_management/features/inventory/data/datasources/inventory_local_data_source.dart';

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  const InventoryLocalDataSourceImpl(this._database);

  static const String productsTable = 'products';

  final Database _database;

  @override
  Future<List<ProductModel>> getProducts() async {
    final rows = await _database.query(
      productsTable,
      orderBy: 'expiry_date ASC',
    );

    return rows.map(ProductModel.fromMap).toList();
  }

  @override
  Future<void> upsertProduct(ProductModel product) async {
    await _database.insert(
      productsTable,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _database.delete(productsTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final rows = await _database.query(
      productsTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return ProductModel.fromMap(rows.first);
  }

  @override
  Future<ProductModel?> getProductByBarcodeAndBatch(
    String barcode,
    String batch,
  ) async {
    final rows = await _database.query(
      productsTable,
      where: 'barcode = ? AND batch = ?',
      whereArgs: [barcode, batch],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return ProductModel.fromMap(rows.first);
  }
}
