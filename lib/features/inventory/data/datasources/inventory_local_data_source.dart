import 'package:inventory_management/features/inventory/data/models/product_model.dart';

abstract class InventoryLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<void> upsertProduct(ProductModel product);
  Future<void> deleteProduct(int id);
  Future<ProductModel?> getProductByBarcode(String barcode);
  Future<ProductModel?> getProductByBarcodeAndBatch(
    String barcode,
    String batch,
  );
}
