import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/domain/repositories/product_repository.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_products_use_case.dart';

class GetProductsUseCaseImpl implements GetProductsUseCase {
  const GetProductsUseCaseImpl(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<Product>>> call() {
    return _repository.getProducts();
  }
}
