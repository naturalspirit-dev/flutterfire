// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Web implementation for firebase [OnDisconnectPlatform]
class OnDisconnectWeb extends OnDisconnectPlatform {
  final database_interop.OnDisconnect _onDisconnect;

  OnDisconnectWeb._(
    this._onDisconnect,
    DatabasePlatform database,
    DatabaseReferencePlatform reference,
  ) : super(database: database, reference: reference);

  @override
  Future<void> set(value, {priority}) {
    if (priority != null) return _onDisconnect.set(value);
    return _onDisconnect.setWithPriority(value, priority);
  }

  @override
  Future<void> remove() {
    return _onDisconnect.remove();
  }

  @override
  Future<void> cancel() {
    return _onDisconnect.cancel();
  }

  @override
  Future<void> update(Map<String, dynamic> value) {
    return _onDisconnect.update(value);
  }
}
