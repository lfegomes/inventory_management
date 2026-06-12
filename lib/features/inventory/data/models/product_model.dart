import 'package:inventory_management/features/inventory/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.barcode,
    required super.name,
    required super.batch,
    required super.quantity,
    required super.expiryDate,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      name: map['name'] as String,
      batch: map['batch'] as String,
      quantity: map['quantity'] as int,
      expiryDate: DateTime.parse(map['expiry_date'] as String),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      barcode: product.barcode,
      name: product.name,
      batch: product.batch,
      quantity: product.quantity,
      expiryDate: product.expiryDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'batch': batch,
      'quantity': quantity,
      'expiry_date': expiryDate.toIso8601String(),
    };
  }
}
