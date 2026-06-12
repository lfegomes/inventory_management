import 'package:inventory_management/core/result/result.dart';

abstract class DeleteProductUseCase {
  Future<Result<void>> call(int id);
}
