import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';
import '../widgets/internal/universal_button.dart';

class SignOutButton extends StatelessWidget {
  final FirebaseAuth? auth;
  const SignOutButton({
    Key? key,
    this.auth,
  }) : super(key: key);

  void _signOut() {
    (auth ?? FirebaseAuth.instance).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    return UniversalButton(
      text: l.signOutButtonText,
      onPressed: _signOut,
      icon: isCupertino ? CupertinoIcons.arrow_right_circle : Icons.logout,
    );
  }
}
