import 'package:flutter/material.dart';

import 'package:inventory_management/core/di/injection.dart';
import 'package:inventory_management/core/result/result.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_and_batch_use_case.dart';
import 'package:inventory_management/features/inventory/viewmodel/inventory_cubit.dart';

class ProductFormView extends StatefulWidget {
  const ProductFormView({
    required this.cubit,
    this.barcode,
    this.existingProduct,
    super.key,
  });

  final InventoryCubit cubit;
  final String? barcode;
  final Product? existingProduct;

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _quantityController = TextEditingController();

  DateTime? _selectedExpiryDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.barcode != null) {
      _barcodeController.text = widget.barcode!;
    }

    if (widget.existingProduct != null) {
      final product = widget.existingProduct!;
      _barcodeController.text = product.barcode;
      _nameController.text = product.name;
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _batchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBarcodeReadOnly = widget.barcode != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Produto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _barcodeController,
                keyboardType: TextInputType.number,
                readOnly: isBarcodeReadOnly,
                decoration: const InputDecoration(
                  labelText: 'Codigo de barras',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o codigo de barras.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do produto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(labelText: 'Lote'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o lote.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Informe uma quantidade valida.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _pickExpiryDate,
                child: Text(
                  _selectedExpiryDate == null
                      ? 'Selecionar data de validade'
                      : 'Validade: ${_formatDate(_selectedExpiryDate!)}',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (_selectedExpiryDate == null) {
      _showMessage('Selecione a data de validade.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final barcode = _barcodeController.text.trim();
    final batch = _batchController.text.trim();

    try {
      final existingByBatch = await getIt<GetProductByBarcodeAndBatchUseCase>()
          .call(barcode, batch);

      if (existingByBatch != null && mounted) {
        setState(() {
          _isSaving = false;
        });

        await _showDuplicateBatchDialog(existingByBatch);
        return;
      }
    } catch (e) {
      // Continuar mesmo se houver erro na verificação
    }

    final product = Product(
      id: widget.existingProduct?.id,
      barcode: barcode,
      name: _nameController.text.trim(),
      batch: batch,
      quantity: int.parse(_quantityController.text.trim()),
      expiryDate: _selectedExpiryDate!,
    );

    final result = await widget.cubit.upsertProduct(product);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (result.isSuccess) {
      Navigator.of(context).pop();
      return;
    }

    final message =
        result is Failure<void> ? result.message : 'Nao foi possivel salvar.';
    _showMessage(message);
  }

  Future<void> _showDuplicateBatchDialog(Product existingProduct) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Lote Duplicado'),
            content: Text(
              'O lote "${existingProduct.batch}" já existe no banco de dados.\n\n'
              'O que deseja fazer?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _handleSumQuantity(existingProduct);
                },
                child: const Text('Somar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _handleOverwrite(existingProduct);
                },
                child: const Text('Sobreescrever'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleSumQuantity(Product existingProduct) async {
    setState(() {
      _isSaving = true;
    });

    final newQuantity = int.parse(_quantityController.text.trim());
    final totalQuantity = existingProduct.quantity + newQuantity;

    final product = Product(
      id: existingProduct.id,
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      batch: _batchController.text.trim(),
      quantity: totalQuantity,
      expiryDate: _selectedExpiryDate!,
    );

    final result = await widget.cubit.upsertProduct(product);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (result.isSuccess) {
      Navigator.of(context).pop();
      return;
    }

    final message =
        result is Failure<void> ? result.message : 'Nao foi possivel salvar.';
    _showMessage(message);
  }

  Future<void> _handleOverwrite(Product existingProduct) async {
    setState(() {
      _isSaving = true;
    });

    final product = Product(
      id: existingProduct.id,
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      batch: _batchController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      expiryDate: _selectedExpiryDate!,
    );

    final result = await widget.cubit.upsertProduct(product);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (result.isSuccess) {
      Navigator.of(context).pop();
      return;
    }

    final message =
        result is Failure<void> ? result.message : 'Nao foi possivel salvar.';
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
