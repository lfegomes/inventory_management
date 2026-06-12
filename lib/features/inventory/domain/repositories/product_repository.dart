import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();

  Future<Result<void>> upsertProduct(Product product);

  Future<Result<void>> deleteProduct(int id);

  Future<Product?> getProductByBarcode(String barcode);

  Future<Product?> getProductByBarcodeAndBatch(String barcode, String batch);
}
