import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/domain/repositories/product_repository.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_use_case.dart';

class GetProductByBarcodeUseCaseImpl implements GetProductByBarcodeUseCase {
  const GetProductByBarcodeUseCaseImpl(this._repository);

  final ProductRepository _repository;

  @override
  Future<Product?> call(String barcode) async {
    return await _repository.getProductByBarcode(barcode);
  }
}
