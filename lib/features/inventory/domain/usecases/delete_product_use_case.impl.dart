import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/domain/repositories/product_repository.dart';
import 'package:inventory_management/features/inventory/domain/usecases/delete_product_use_case.dart';

class DeleteProductUseCaseImpl implements DeleteProductUseCase {
  const DeleteProductUseCaseImpl(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<void>> call(int id) {
    return _repository.deleteProduct(id);
  }
}
