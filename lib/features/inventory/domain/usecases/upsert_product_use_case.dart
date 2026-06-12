import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';

abstract class UpsertProductUseCase {
  Future<Result<void>> call(Product product);
}
