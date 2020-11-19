// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase/firebase.dart' as fb;

import '../list_result_web.dart';

/// Converts ListOptions from the plugin to ListOptions for the JS interop layer.
fb.ListOptions listOptionsToFbListOptions(ListOptions options) {
  if (options == null) {
    return null;
  }

  return fb.ListOptions(
    maxResults: options.maxResults,
    pageToken: options.pageToken,
  );
}

/// Converts a ListResult from the JS interop layer to a ListResultWeb for the plugin.
ListResultWeb fbListResultToListResultWeb(
    FirebaseStoragePlatform storage, fb.ListResult result) {
  if (result == null) {
    return null;
  }

  return ListResultWeb(
    storage,
    nextPageToken: result.nextPageToken,
    items: result.items?.map<String>((item) => item.fullPath)?.toList(),
    prefixes:
        result.prefixes?.map<String>((prefix) => prefix.fullPath)?.toList(),
  );
}
