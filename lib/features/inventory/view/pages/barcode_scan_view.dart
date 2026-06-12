import 'package:flutter/material.dart';
import 'package:inventory_management/features/inventory/view/pages/product_form_view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:inventory_management/core/di/injection.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_use_case.dart';
import 'package:inventory_management/features/inventory/viewmodel/inventory_cubit.dart';

class BarcodeScanView extends StatefulWidget {
  const BarcodeScanView({required this.cubit, super.key});

  final InventoryCubit cubit;

  @override
  State<BarcodeScanView> createState() => _BarcodeScanViewState();
}

class _BarcodeScanViewState extends State<BarcodeScanView> {
  late MobileScannerController _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler Código de Barras'),
        centerTitle: true,
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _isProcessing ? null : _handleBarcodeDetection,
      ),
    );
  }

  void _handleBarcodeDetection(BarcodeCapture barcodes) async {
    if (_isProcessing || barcodes.barcodes.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final barcode = barcodes.barcodes.first.rawValue ?? '';

    if (barcode.isEmpty) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      final getProductByBarcodeUseCase = getIt<GetProductByBarcodeUseCase>();
      final product = await getProductByBarcodeUseCase(barcode);

      if (!mounted) {
        return;
      }

      final navigator = Navigator.of(context);

      await _scannerController.stop();

      if (product != null) {
        await navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder:
                (_) => ProductFormView(
                  cubit: widget.cubit,
                  existingProduct: product,
                  barcode: barcode,
                ),
          ),
        );
      } else {
        await navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder:
                (_) => ProductFormView(cubit: widget.cubit, barcode: barcode),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao processar código: $e')));

      await _scannerController.start();
    }
  }
}
