import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'package:inventory_management/core/database/app_database.dart';
import 'package:inventory_management/core/notifications/notification_service.dart';
import 'package:inventory_management/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:inventory_management/features/inventory/data/datasources/inventory_local_data_source.impl.dart';
import 'package:inventory_management/features/inventory/data/repositories/product_repository.impl.dart';
import 'package:inventory_management/features/inventory/domain/repositories/product_repository.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_and_batch_use_case.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_and_batch_use_case.impl.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_use_case.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_product_by_barcode_use_case.impl.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_products_use_case.dart';
import 'package:inventory_management/features/inventory/domain/usecases/get_products_use_case.impl.dart';
import 'package:inventory_management/features/inventory/domain/usecases/delete_product_use_case.dart';
import 'package:inventory_management/features/inventory/domain/usecases/delete_product_use_case.impl.dart';
import 'package:inventory_management/features/inventory/domain/usecases/upsert_product_use_case.dart';
import 'package:inventory_management/features/inventory/domain/usecases/upsert_product_use_case.impl.dart';
import 'package:inventory_management/features/inventory/viewmodel/inventory_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final database = await AppDatabase().open();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final notificationService = NotificationService(notificationsPlugin);
  await notificationService.init();
  getIt.registerSingleton<NotificationService>(notificationService);

  getIt.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSourceImpl(database),
  );

  getIt.registerFactory<ProductRepository>(
    () => ProductRepositoryImpl(getIt()),
  );

  getIt.registerFactory<GetProductsUseCase>(
    () => GetProductsUseCaseImpl(getIt()),
  );

  getIt.registerFactory<UpsertProductUseCase>(
    () => UpsertProductUseCaseImpl(getIt()),
  );

  getIt.registerFactory<DeleteProductUseCase>(
    () => DeleteProductUseCaseImpl(getIt()),
  );

  getIt.registerFactory<GetProductByBarcodeUseCase>(
    () => GetProductByBarcodeUseCaseImpl(getIt()),
  );

  getIt.registerFactory<GetProductByBarcodeAndBatchUseCase>(
    () => GetProductByBarcodeAndBatchUseCaseImpl(getIt()),
  );

  getIt.registerFactory<InventoryCubit>(
    () => InventoryCubit(
      getProductsUseCase: getIt(),
      upsertProductUseCase: getIt(),
      deleteProductUseCase: getIt(),
      notificationService: getIt(),
    ),
  );
}
