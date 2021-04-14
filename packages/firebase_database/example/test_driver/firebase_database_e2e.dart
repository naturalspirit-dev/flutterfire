// @dart = 2.9
import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
  group('FirebaseDatabase', () {
    setUp(() async {
      await Firebase.initializeApp();
    });

    test('runTransaction', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      final DatabaseReference ref = database.reference().child('counter');
      final DataSnapshot snapshot = await ref.once();
      final int value = snapshot.value ?? 0;
      final TransactionResult transactionResult =
          await ref.runTransaction((MutableData mutableData) async {
        mutableData.value = (mutableData.value ?? 0) + 1;
        return mutableData;
      });
      expect(transactionResult.committed, true);
      expect(transactionResult.dataSnapshot.value > value, true);
    });

    test('setPersistenceCacheSizeBytes Integer', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;

      await database.setPersistenceCacheSizeBytes(2147483647);
    });

    test('setPersistenceCacheSizeBytes Long', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      await database.setPersistenceCacheSizeBytes(2147483648);
    });
  });
}

void main() => drive.main(testsMain);
