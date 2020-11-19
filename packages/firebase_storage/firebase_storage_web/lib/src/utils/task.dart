// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase/firebase.dart' as fb;

import '../task_snapshot_web.dart';

Map<fb.TaskState, TaskState> _fbTaskStateToTaskState = {
  fb.TaskState.CANCELED: TaskState.canceled,
  fb.TaskState.ERROR: TaskState.error,
  fb.TaskState.PAUSED: TaskState.paused,
  fb.TaskState.RUNNING: TaskState.running,
  fb.TaskState.SUCCESS: TaskState.success,
};

/// Converts TaskStates from the JS interop layer to TaskStates for the plugin
TaskState fbTaskStateToTaskState(fb.TaskState state) {
  if (state == null) {
    return null;
  }

  return _fbTaskStateToTaskState[state];
}

/// Converts UploadTaskSnapshot from the JS interop layer to TaskSnapshotWeb for the plugin.
TaskSnapshotWeb fbUploadTaskSnapshotToTaskSnapshot(
    ReferencePlatform reference, fb.UploadTaskSnapshot snapshot) {
  if (snapshot == null) {
    return null;
  }

  return TaskSnapshotWeb(reference, snapshot);
}
