import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/database/database_helper.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
