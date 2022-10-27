## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - Update a dependency to the latest release.

## 1.0.1

 - **FIX**: bump dependencies ([#9756](https://github.com/firebase/flutterfire/issues/9756)). ([595a7daa](https://github.com/firebase/flutterfire/commit/595a7daa3e856cad152463e543d152f71f61cee9))

## 1.0.0

 - Graduate package to a stable release.

To migrate from `flutterfire_ui` to `firebase_ui_database` you need to update your dependencies:

```diff
dependencies:
-  flutterfire_ui: ^0.4.0
+  firebase_ui_database: ^1.0.0
```

and imports:

```diff
- import 'package:flutterfire_ui/database.dart';
+ import 'package:firebase_ui_database/firebase_ui_database.dart';
```

## 1.0.0-dev.2

 - Update a dependency to the latest release.

## 1.0.0-dev.1

 - **FIX**: improve pub score ([#9722](https://github.com/firebase/flutterfire/issues/9722)). ([f27d89a1](https://github.com/firebase/flutterfire/commit/f27d89a12cbb5830eb5518854dcfbca72efedb5b))
 - **FEAT**: add firebase_ui_database ([#9341](https://github.com/firebase/flutterfire/issues/9341)). ([49e1beb5](https://github.com/firebase/flutterfire/commit/49e1beb514aae652c962f6b72a6539b01ca6915f))

## 1.0.0-dev.0

 - Bump "firebase_ui_database" to `1.0.0-dev.0`.

## 0.0.1

* TODO: Describe initial release.
