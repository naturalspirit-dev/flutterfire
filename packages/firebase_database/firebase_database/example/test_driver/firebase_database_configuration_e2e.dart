import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

const MAX_CACHE_SIZE = 100 * 1024 * 1024;
const MIN_CACHE_SIZE = 1042 * 1024;

void runConfigurationTests() {
  group('FirebaseDatabase configuration', () {
    test(
      'setPersistenceCacheSizeBytes Integer',
      () {
        database.setPersistenceCacheSizeBytes(MIN_CACHE_SIZE);
      },
      // Skipped because it is not supported on web
      skip: kIsWeb,
    );

    test(
      'setPersistenceCacheSizeBytes Long',
      () {
        database.setPersistenceCacheSizeBytes(MAX_CACHE_SIZE);
      },
      // Skipped because it is not supported on web
      skip: kIsWeb,
    );

    test('setLoggingEnabled to true', () {
      database.setLoggingEnabled(true);
    });

    test('setLoggingEnabled to false', () {
      database.setLoggingEnabled(false);
    });
  });
}
