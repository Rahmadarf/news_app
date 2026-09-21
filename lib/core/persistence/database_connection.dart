import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the on-disk database in a background isolate, so queries never block
/// the UI isolate.
QueryExecutor openAppDatabaseFile({String fileName = 'news_app.sqlite'}) {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationSupportDirectory();
    final File file = File(p.join(directory.path, fileName));
    return NativeDatabase.createInBackground(file);
  });
}

/// In-memory executor for tests. Each call yields an isolated database.
QueryExecutor openInMemoryDatabase() => NativeDatabase.memory();
