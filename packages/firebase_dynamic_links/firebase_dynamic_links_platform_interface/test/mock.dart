// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_dynamic_links_platform_interface/src/method_channel/method_channel_firebase_dynamic_links.dart';

typedef MethodCallCallback = dynamic Function(MethodCall methodCall);
typedef Callback = void Function(MethodCall call);

int mockHandleId = 0;

int get nextMockHandleId => mockHandleId++;

void setupFirebaseDynamicLinksMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    if (customHandlers != null) {
      customHandlers(call);
    }

    return null;
  });
}

void handleMethodCall(MethodCallCallback methodCallCallback) =>
    MethodChannelFirebaseDynamicLinks.channel
        .setMockMethodCallHandler((call) async {
      return await methodCallCallback(call);
    });

void handleEventChannel(
  final String name, [
  List<MethodCall>? log,
]) {
  MethodChannel(name).setMockMethodCallHandler((MethodCall methodCall) async {
    log?.add(methodCall);
    switch (methodCall.method) {
      case 'listen':
        break;
      case 'cancel':
      default:
        return null;
    }
  });
}

Future<void> injectEventChannelResponse(
  String channelName,
  Map<String, dynamic> event,
) async {
  await ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
    channelName,
    MethodChannelFirebaseDynamicLinks.channel.codec
        .encodeSuccessEnvelope(event),
    (_) {},
  );
}

Future<void> testExceptionHandling(
  void Function() testMethod,
) async {
  await expectLater(
    () async => testMethod(),
    anyOf([completes, throwsA(isA<FirebaseException>())]),
  );
}
