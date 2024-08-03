import 'package:flutter_sqflite/services/database_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
}
