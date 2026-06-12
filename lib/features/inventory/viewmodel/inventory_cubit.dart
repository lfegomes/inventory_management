import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:inventory_management/core/notifications/notification_service.dart';
import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/domain/usecases/delete_product_use_case.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_products_use_case.dart';
import 'package:inventory_management/features/inventory/domain/usecases/upsert_product_use_case.dart';
import 'package:inventory_management/features/inventory/viewmodel/inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit({
    required GetProductsUseCase getProductsUseCase,
    required UpsertProductUseCase upsertProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
    required NotificationService notificationService,
  }) : _getProductsUseCase = getProductsUseCase,
       _upsertProductUseCase = upsertProductUseCase,
       _deleteProductUseCase = deleteProductUseCase,
       _notificationService = notificationService,
       super(const InventoryState());

  final GetProductsUseCase _getProductsUseCase;
  final UpsertProductUseCase _upsertProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final NotificationService _notificationService;

  List<Product> get filteredProducts {
    final query = state.searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return state.products;
    }

    return state.products.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> loadProducts() async {
    emit(
      state.copyWith(
        loadStatus: InventoryRequestStatus.loading,
        clearError: true,
      ),
    );

    final result = await _getProductsUseCase();

    if (result case Success<List<Product>>(:final data)) {
      emit(
        state.copyWith(
          loadStatus: InventoryRequestStatus.success,
          products: data,
          clearError: true,
        ),
      );
      return;
    }

    if (result case Failure<List<Product>>(:final message)) {
      emit(
        state.copyWith(
          loadStatus: InventoryRequestStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  Future<Result<void>> upsertProduct(Product product) async {
    emit(
      state.copyWith(
        saveStatus: InventoryRequestStatus.loading,
        clearError: true,
      ),
    );

    final result = await _upsertProductUseCase(product);

    if (result case Failure<void>(:final message)) {
      emit(
        state.copyWith(
          saveStatus: InventoryRequestStatus.failure,
          errorMessage: message,
        ),
      );
      return result;
    }

    await loadProducts();

    Product? saved;
    try {
      saved = state.products.firstWhere(
        (p) => p.barcode == product.barcode && p.batch == product.batch,
      );
    } catch (_) {
      saved = product;
    }
    if (saved.id != null) {
      await _notificationService.scheduleExpiryNotifications(
        productId: saved.id!,
        productName: saved.name,
        expiryDate: saved.expiryDate,
      );
    }

    emit(
      state.copyWith(
        saveStatus: InventoryRequestStatus.success,
        clearError: true,
      ),
    );
    return result;
  }

  Future<Result<void>> checkoutProduct({
    required Product product,
    required int quantityToCheckout,
  }) async {
    if (quantityToCheckout <= 0 || quantityToCheckout > product.quantity) {
      return const Failure<void>('Quantidade de baixa invalida.');
    }

    emit(
      state.copyWith(
        saveStatus: InventoryRequestStatus.loading,
        clearError: true,
      ),
    );

    Result<void> result;

    if (quantityToCheckout == product.quantity) {
      final id = product.id;
      if (id == null) {
        result = const Failure<void>('Produto sem identificador para remocao.');
      } else {
        result = await _deleteProductUseCase(id);
        if (result.isSuccess) {
          await _notificationService.cancelExpiryNotifications(id);
        }
      }
    } else {
      final updatedProduct = product.copyWith(
        quantity: product.quantity - quantityToCheckout,
      );
      result = await _upsertProductUseCase(updatedProduct);
    }

    if (result case Failure<void>(:final message)) {
      emit(
        state.copyWith(
          saveStatus: InventoryRequestStatus.failure,
          errorMessage: message,
        ),
      );
      return result;
    }

    await loadProducts();
    emit(
      state.copyWith(
        saveStatus: InventoryRequestStatus.success,
        clearError: true,
      ),
    );

    return result;
  }
}
