// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Builds [EventPlatform] instance form web event instance
EventPlatform fromWebEventToPlatformEvent(database_interop.QueryEvent event) {
  return EventPlatform.fromDataSnapshotPlatform(
      fromWebSnapshotToPlatformSnapShot(event.snapshot), event.prevChildKey);
}

/// Builds [DataSnapshotPlatform] instance form web snapshot instance
DataSnapshotPlatform fromWebSnapshotToPlatformSnapShot(
    database_interop.DataSnapshot snapshot) {
  return DataSnapshotPlatform(snapshot.key, snapshot.val());
}
