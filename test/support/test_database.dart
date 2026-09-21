import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/persistence/app_database.dart';
import 'package:news_app/core/persistence/database_connection.dart';

/// Fresh in-memory database, closed automatically when the test ends.
AppDatabase newTestDatabase() {
  final AppDatabase db = AppDatabase(openInMemoryDatabase());
  addTearDown(db.close);
  return db;
}

/// Clock whose current time the test moves by hand.
///
/// TTL behaviour is verified by advancing [now]; no test ever waits on a real
/// timer.
class MutableClock {
  MutableClock(this.now);

  DateTime now;

  Clock get clock => Clock(() => now);

  void advance(Duration duration) => now = now.add(duration);
}
