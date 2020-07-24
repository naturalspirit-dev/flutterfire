// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

@interface FLTFirebaseDatabasePlugin : NSObject <FlutterPlugin>

@property(nonatomic) NSMutableDictionary *updatedSnapshots;

@end
