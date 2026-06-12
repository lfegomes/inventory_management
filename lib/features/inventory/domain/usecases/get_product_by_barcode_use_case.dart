import 'package:inventory_management/features/inventory/domain/entities/product.dart';

abstract class GetProductByBarcodeUseCase {
  Future<Product?> call(String barcode);
}
