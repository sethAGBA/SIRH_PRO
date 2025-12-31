import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/sqlite_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SQLiteService().init();
  runApp(const SirhProApp());
}
