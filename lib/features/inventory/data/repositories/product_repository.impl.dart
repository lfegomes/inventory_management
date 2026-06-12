import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:inventory_management/features/inventory/data/models/product_model.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._localDataSource);

  final InventoryLocalDataSource _localDataSource;

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final products = await _localDataSource.getProducts();
      return Success<List<Product>>(products);
    } catch (error) {
      return Failure<List<Product>>(
        'Nao foi possivel carregar os produtos.',
        error,
      );
    }
  }

  @override
  Future<Result<void>> upsertProduct(Product product) async {
    try {
      await _localDataSource.upsertProduct(ProductModel.fromEntity(product));
      return const Success<void>(null);
    } catch (error) {
      return Failure<void>('Nao foi possivel salvar o produto.', error);
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      await _localDataSource.deleteProduct(id);
      return const Success<void>(null);
    } catch (error) {
      return Failure<void>('Nao foi possivel remover o produto.', error);
    }
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    return await _localDataSource.getProductByBarcode(barcode);
  }

  @override
  Future<Product?> getProductByBarcodeAndBatch(
    String barcode,
    String batch,
  ) async {
    return await _localDataSource.getProductByBarcodeAndBatch(barcode, batch);
  }
}
