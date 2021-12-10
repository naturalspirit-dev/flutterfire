// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_analytics;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
export 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart'
    show AnalyticsEventItem, AnalyticsCallOptions;

part 'src/firebase_analytics.dart';
part 'src/observer.dart';
