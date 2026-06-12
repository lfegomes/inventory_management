import 'package:inventory_management/features/inventory/domain/entities/product.dart';

enum InventoryRequestStatus { initial, loading, success, failure }

class InventoryState {
  const InventoryState({
    this.loadStatus = InventoryRequestStatus.initial,
    this.saveStatus = InventoryRequestStatus.initial,
    this.products = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  final InventoryRequestStatus loadStatus;
  final InventoryRequestStatus saveStatus;
  final List<Product> products;
  final String searchQuery;
  final String? errorMessage;

  InventoryState copyWith({
    InventoryRequestStatus? loadStatus,
    InventoryRequestStatus? saveStatus,
    List<Product>? products,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventoryState(
      loadStatus: loadStatus ?? this.loadStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
