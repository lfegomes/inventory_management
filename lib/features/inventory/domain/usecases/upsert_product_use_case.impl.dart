import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/domain/repositories/product_repository.dart';
import 'package:inventory_management/features/inventory/domain/usecases/upsert_product_use_case.dart';

class UpsertProductUseCaseImpl implements UpsertProductUseCase {
  const UpsertProductUseCaseImpl(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<void>> call(Product product) {
    return _repository.upsertProduct(product);
  }
}
