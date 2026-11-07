import 'dart:io';

import 'package:autolog/data/database/app_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void setUpTestDatabase() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    directory = await Directory.systemTemp.createTemp('autolog-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => directory.path);
  });

  setUp(() async {
    final db = await AppDatabase.instance.database;
    await db.transaction((transaction) async {
      for (final table in [
        'expenses',
        'service_reminders',
        'vehicles',
        'app_settings',
      ]) {
        await transaction.delete(table);
      }
    });
  });

  tearDownAll(() async {
    await AppDatabase.instance.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await directory.delete(recursive: true);
  });
}
