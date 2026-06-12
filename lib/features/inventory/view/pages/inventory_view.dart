import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:inventory_management/core/di/injection.dart';
import 'package:inventory_management/features/inventory/domain/entities/product.dart';
import 'package:inventory_management/features/inventory/view/pages/barcode_scan_view.dart';
import 'package:inventory_management/features/inventory/view/pages/product_form_view.dart';
import 'package:inventory_management/features/inventory/viewmodel/inventory_cubit.dart';
import 'package:inventory_management/features/inventory/viewmodel/inventory_state.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  late final InventoryCubit _cubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<InventoryCubit>()..loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Controle de Estoque'),
          toolbarHeight: 70,
          elevation: 4,
          shadowColor: Colors.black,
        ),
        body: BlocBuilder<InventoryCubit, InventoryState>(
          bloc: _cubit,
          builder: (context, state) {
            final products = _cubit.filteredProducts;

            if (state.loadStatus == InventoryRequestStatus.loading &&
                state.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.loadStatus == InventoryRequestStatus.failure &&
                state.products.isEmpty) {
              return Center(
                child: Text(state.errorMessage ?? 'Erro ao carregar produtos.'),
              );
            }

            if (state.products.isEmpty) {
              return const Center(child: Text('Nenhum produto cadastrado.'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _cubit.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _cubit.updateSearchQuery('');
                                },
                                icon: const Icon(Icons.close),
                                tooltip: 'Limpar busca',
                              ),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      products.isEmpty
                          ? const Center(
                            child: Text('Nenhum produto encontrado.'),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: products.length,
                            separatorBuilder:
                                (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final daysLeft =
                                  product.expiryDate
                                      .difference(DateTime.now())
                                      .inDays;
                              final isNearExpiry = daysLeft < 10;

                              return ListTile(
                                tileColor:
                                    isNearExpiry
                                        ? Colors.red.shade100
                                        : Colors.grey.shade100,
                                title: Text(
                                  product.name,
                                  style: TextStyle(
                                    color:
                                        isNearExpiry
                                            ? Colors.red.shade800
                                            : null,
                                    fontWeight:
                                        isNearExpiry ? FontWeight.bold : null,
                                  ),
                                ),
                                subtitle: Text(
                                  'Lote: ${product.batch} | Qtd: ${product.quantity}\n'
                                  'Validade: ${_formatDate(product.expiryDate)}',
                                  style: TextStyle(
                                    color:
                                        isNearExpiry
                                            ? Colors.red.shade700
                                            : null,
                                  ),
                                ),
                                isThreeLine: true,
                                dense: true,
                                onTap: () => _showProductActions(product),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'manual',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductFormView(cubit: _cubit),
                  ),
                );
              },
              tooltip: 'Cadastrar manualmente',
              icon: const Icon(Icons.add),
              label: const Text('Manual'),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'scan',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BarcodeScanView(cubit: _cubit),
                  ),
                );
              },
              tooltip: 'Ler código de barras',
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _showProductActions(Product product) async {
    final action = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Produto'),
            content: const Text('Deseja dar baixa neste item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('checkout'),
                child: const Text('Dar baixa'),
              ),
            ],
          ),
    );

    if (!mounted || action != 'checkout') {
      return;
    }

    await _showCheckoutDialog(product);
  }

  Future<void> _showCheckoutDialog(Product product) async {
    final quantityController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Dar baixa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantidade atual: ${product.quantity}'),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade para baixa',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (!mounted || confirmed != true) {
      quantityController.dispose();
      return;
    }

    final quantityToCheckout = int.tryParse(quantityController.text.trim());
    quantityController.dispose();

    if (quantityToCheckout == null) {
      _showMessage('Informe uma quantidade valida.');
      return;
    }

    final result = await _cubit.checkoutProduct(
      product: product,
      quantityToCheckout: quantityToCheckout,
    );

    if (!mounted) {
      return;
    }

    if (result.isFailure) {
      _showMessage(result.errorMessage ?? 'Nao foi possivel dar baixa.');
      return;
    }

    _showMessage('Baixa registrada com sucesso.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
