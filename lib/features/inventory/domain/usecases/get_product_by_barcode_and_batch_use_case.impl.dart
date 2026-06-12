import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/domain/repositories/product_repository.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_and_batch_use_case.dart';

class GetProductByBarcodeAndBatchUseCaseImpl
    implements GetProductByBarcodeAndBatchUseCase {
  const GetProductByBarcodeAndBatchUseCaseImpl(this._repository);

  final ProductRepository _repository;

  @override
  Future<Product?> call(String barcode, String batch) async {
    return await _repository.getProductByBarcodeAndBatch(barcode, batch);
  }
}
