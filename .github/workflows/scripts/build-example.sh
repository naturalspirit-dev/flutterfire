#!/bin/bash

ACTION=$1

melos bootstrap

if [ "$ACTION" == "android" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build apk --debug --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi

if [ "$ACTION" == "ios" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build ios --no-codesign --simulator --debug --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi

if [ "$ACTION" == "macos" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build macos --debug --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi

if [ "$ACTION" == "web" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=web -- \
    flutter build web
  exit
fi
