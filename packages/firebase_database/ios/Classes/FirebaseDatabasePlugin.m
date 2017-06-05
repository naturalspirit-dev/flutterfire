#import "FirebaseDatabasePlugin.h"

#import <Firebase/Firebase.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

FIRDatabaseReference *getReference(NSDictionary *arguments) {
  NSString *path = arguments[@"path"];
  FIRDatabaseReference *ref = [FIRDatabase database].reference;
  if ([path length] > 0) ref = [ref child:path];
  return ref;
}

FIRDatabaseQuery *getQuery(NSDictionary *arguments) {
  FIRDatabaseQuery *query = getReference(arguments);
  NSDictionary *parameters = arguments[@"parameters"];
  NSString *orderBy = parameters[@"orderBy"];
  if ([orderBy isEqualToString:@"child"]) {
    query = [query queryOrderedByChild:parameters[@"orderByChildKey"]];
  } else if ([orderBy isEqualToString:@"key"]) {
    query = [query queryOrderedByKey];
  } else if ([orderBy isEqualToString:@"value"]) {
    query = [query queryOrderedByValue];
  } else if ([orderBy isEqualToString:@"priority"]) {
    query = [query queryOrderedByPriority];
  }
  id startAt = parameters[@"startAt"];
  if (startAt) {
    query = [query queryStartingAtValue:startAt childKey:parameters[@"endAtKey"]];
  }
  id endAt = parameters[@"endAt"];
  if (endAt) {
    query = [query queryEndingAtValue:endAt childKey:parameters[@"endAtKey"]];
  }
  id equalTo = parameters[@"equalTo"];
  if (equalTo) {
    query = [query queryEqualToValue:equalTo];
  }
  NSNumber *limitToFirst = parameters[@"limitToFirst"];
  if (limitToFirst) {
    query = [query queryLimitedToFirst:limitToFirst.intValue];
  }
  NSNumber *limitToLast = parameters[@"limitToLast"];
  if (limitToLast) {
    query = [query queryLimitedToLast:limitToLast.intValue];
  }
  return query;
}

FIRDataEventType parseEventType(NSString *eventTypeString) {
  if ([@"_EventType.childAdded" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildAdded;
  } else if ([@"_EventType.childRemoved" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildRemoved;
  } else if ([@"_EventType.childChanged" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildChanged;
  } else if ([@"_EventType.childMoved" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildMoved;
  } else if ([@"_EventType.value" isEqual:eventTypeString]) {
    return FIRDataEventTypeValue;
  }
  assert(false);
  return 0;
}

@interface FirebaseDatabasePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseDatabasePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_database"
                                  binaryMessenger:[registrar messenger]];
  FirebaseDatabasePlugin *instance = [[FirebaseDatabasePlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  void (^defaultCompletionBlock)(NSError *, FIRDatabaseReference *) =
      ^(NSError *error, FIRDatabaseReference *ref) {
        result(error.flutterError);
      };
  if ([@"FirebaseDatabase#goOnline" isEqualToString:call.method]) {
    [[FIRDatabase database] goOnline];
  } else if ([@"FirebaseDatabase#goOffline" isEqualToString:call.method]) {
    [[FIRDatabase database] goOffline];
  } else if ([@"FirebaseDatabase#purgeOutstandingWrites" isEqualToString:call.method]) {
    [[FIRDatabase database] purgeOutstandingWrites];
  } else if ([@"FirebaseDatabase#setPersistenceEnabled" isEqualToString:call.method]) {
    NSNumber *value = call.arguments[@"value"];
    [FIRDatabase database].persistenceEnabled = value.boolValue;
  } else if ([@"FirebaseDatabase#setPersistenceCacheSizeBytes" isEqualToString:call.method]) {
    NSNumber *value = call.arguments[@"value"];
    [FIRDatabase database].persistenceCacheSizeBytes = value.unsignedIntegerValue;
  } else if ([@"DatabaseReference#set" isEqualToString:call.method]) {
    [getReference(call.arguments) setValue:call.arguments[@"value"]
                               andPriority:call.arguments[@"priority"]
                       withCompletionBlock:defaultCompletionBlock];
  } else if ([@"DatabaseReference#setPriority" isEqualToString:call.method]) {
    [getReference(call.arguments) setPriority:call.arguments[@"priority"]
                          withCompletionBlock:defaultCompletionBlock];
  } else if ([@"Query#observe" isEqualToString:call.method]) {
    FIRDataEventType eventType = parseEventType(call.arguments[@"eventType"]);
    __block FIRDatabaseHandle handle = [getQuery(call.arguments)
                      observeEventType:eventType
        andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousSiblingKey) {
          [self.channel invokeMethod:@"Event"
                           arguments:@{
                             @"handle" : [NSNumber numberWithUnsignedInteger:handle],
                             @"snapshot" : @{
                               @"key" : snapshot.key ?: [NSNull null],
                               @"value" : snapshot.value ?: [NSNull null],
                             },
                             @"previousSiblingKey" : previousSiblingKey ?: [NSNull null],
                           }];
        }];
    result([NSNumber numberWithUnsignedInteger:handle]);
  } else if ([@"Query#removeObserver" isEqualToString:call.method]) {
    FIRDatabaseHandle handle = [call.arguments[@"handle"] unsignedIntegerValue];
    [getQuery(call.arguments) removeObserverWithHandle:handle];
    result(nil);
  } else if ([@"Query#keepSynced" isEqualToString:call.method]) {
    NSNumber *value = call.arguments[@"value"];
    [getQuery(call.arguments) keepSynced:value];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
