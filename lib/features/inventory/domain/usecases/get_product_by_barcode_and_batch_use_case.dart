import 'package:inventory_management/features/inventory/domain/entities/product.dart';

abstract class GetProductByBarcodeAndBatchUseCase {
  Future<Product?> call(String barcode, String batch);
}
