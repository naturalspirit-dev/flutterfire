import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const home = Scaffold(
    body: LoadingIndicator(
      size: 30,
      borderWidth: 2,
    ),
  );

  group('LoadingIndicator', () {
    testWidgets(
      'uses CircularProgressIndicator under MaterialApp',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: home));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'uses CupertinoActivityIndicator under MaterialApp',
      (tester) async {
        await tester.pumpWidget(const CupertinoApp(home: home));
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'centered under both MaterialApp and CupertinoApp',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: home));
        expect(find.byType(Center), findsOneWidget);

        await tester.pumpWidget(const CupertinoApp(home: home));
        expect(find.byType(Center), findsOneWidget);
      },
    );
  });
}
