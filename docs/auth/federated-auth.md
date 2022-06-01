Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Federated identity & social sign-in

Social authentication is a multi-step authentication flow, allowing you to sign a user into an account or link
them with an existing one.

Both native platforms and web support creating a credential which can then be passed to the `signInWithCredential`
or `linkWithCredential` methods. Alternatively on web platforms, you can trigger the authentication process via
a popup or redirect.

## Google

Most configuration is already setup when using Google Sign-In with Firebase, however you need to ensure your machine's
SHA1 key has been configured for use with Android. You can see how to generate the key on the
[Installation](../manual-installation/android#generating-firebase-credentials) documentation.

Ensure the "Google" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers).

> If your user signs in with Google, after having already manually registered an account, their authentication provider will automatically
> change to Google, due to Firebase Authentications concept of trusted providers. You can find out more about
> this [here](https://groups.google.com/g/firebase-talk/c/ms_NVQem_Cw/m/8g7BFk1IAAAJ).

* {iOS+ and Android}

  On native platforms, a 3rd party library is required to trigger the authentication flow.

  Install the official [`google_sign_in`](https://pub.dev/packages/google_sign_in) plugin.

  Once installed, trigger the sign-in flow and create a new credential:

  ```dart
  import 'package:google_sign_in/google_sign_in.dart';

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  ```

* {Web}

  On the web, the Firebase SDK provides support for automatically handling the authentication flow using your Firebase project. For example:

  Create a Google auth provider, providing any additional [permission scope](https://developers.google.com/identity/protocols/oauth2/scopes)
  you wish to obtain from the user:

  ```dart
  GoogleAuthProvider googleProvider = GoogleAuthProvider();

  googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
  googleProvider.setCustomParameters({
    'login_hint': 'user@example.com'
  });
  ```

  Provide the credential to the `signInWithPopup` method. This will trigger a new
  window to appear prompting the user to sign-in to your project. Alternatively you can use `signInWithRedirect` to keep the
  authentication process in the same window.

  ```dart
  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com'
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }
  ```


## Facebook

Before getting started setup your [Facebook Developer App](https://developers.facebook.com/apps/) and follow the setup process to enable Facebook Login.

Ensure the "Facebook" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers).
with the Facebook App ID and Secret set.

* {iOS+ and Android}

  On native platforms, a 3rd party library is required to both install the Facebook SDK and trigger the authentication flow.

  Install the [`flutter_facebook_auth`](https://pub.dev/packages/flutter_facebook_auth) plugin.

  You will need to follow the steps in the plugin documentation to ensure that both the Android & iOS Facebook SDKs have been initialized
  correctly. Once complete, trigger the sign-in flow, create a Facebook credential and sign the user in:

  ```dart
  import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
  ```

* {Web}

  On the web, the Firebase SDK provides support for automatically handling the authentication flow using the
  Facebook application details provided on the Firebase console. For example:

  Create a Facebook provider, providing any additional [permission scope](https://developers.facebook.com/docs/facebook-login/permissions/)
  you wish to obtain from the user.

  Ensure that the OAuth redirect URI from the Firebase console is added as a valid OAuth Redirect URI
  in your Facebook App.

  ```dart
  FacebookAuthProvider facebookProvider = FacebookAuthProvider();

  facebookProvider.addScope('email');
  facebookProvider.setCustomParameters({
    'display': 'popup',
  });
  ```

  Provide the credential to the `signInWithPopup` method. This will trigger a new
  window to appear prompting the user to sign-in to your Facebook application:

  ```dart
  Future<UserCredential> signInWithFacebook() async {
    // Create a new provider
    FacebookAuthProvider facebookProvider = FacebookAuthProvider();

    facebookProvider.addScope('email');
    facebookProvider.setCustomParameters({
      'display': 'popup',
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(facebookProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(facebookProvider);
  }
  ```

Note: Firebase will not set the `User.emailVerified` property
to `true` if your user logs in with Facebook. Should your user login using a provider that verifies email (e.g. Google sign-in) then this will be set to true.
For further information, see this [issue](https://github.com/firebase/flutterfire/issues/4612#issuecomment-782107867).


## Apple

* {iOS+ and Android}

  Before you begin [configure Sign In with Apple](/docs/auth/ios/apple#configure-sign-in-with-apple)
  and [enable Apple as a sign-in provider](/docs/auth/ios/apple#enable-apple-as-a-sign-in-provider).

  Next, make sure that your `Runner` apps have the "Sign in with Apple" capability.

  Install the [`sign_in_with_apple`](https://pub.dev/packages/sign_in_with_apple) plugin, as well as the
  [`crypto`](https://pub.dev/packages/crypto) package:

  ```yaml title="pubspec.yaml"
  dependencies:
    sign_in_with_apple: ^3.0.0
    crypto: ^3.0.1
  ```

  ```dart
  import 'dart:convert';
  import 'dart:math';

  import 'package:crypto/crypto.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:sign_in_with_apple/sign_in_with_apple.dart';

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }
  ```

* {Web}

  Before you begin [configure Sign In with Apple](/docs/auth/web/apple#configure-sign-in-with-apple)
  and [enable Apple as a sign-in provider](/docs/auth/web/apple#enable-apple-as-a-sign-in-provider).

  ```dart
  import 'package:firebase_auth/firebase_auth.dart';

  Future<UserCredential> signInWithApple() async {
    // Create and configure an OAuthProvider for Sign In with Apple.
    final provider = OAuthProvider("apple.com")
      ..addScope('email')
      ..addScope('name');

    // Sign in the user with Firebase.
    return await FirebaseAuth.instance.signInWithPopup(provider);
  }
  ```

  An alternative is to use `signInWithRedirect`. In that case the browser will navigate away from your app
  and you have to use `getRedirectResult` to check for authentication results during app startup.


## Twitter

Ensure the "Twitter" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers)
with an API Key and API Secret set.

* {iOS+ and Android}

  On native platforms, a 3rd party library is required to both install the Twitter SDK and trigger the authentication flow.

  Install the [`twitter_login`](https://pub.dev/packages/twitter_login) plugin:

  ```yaml title="pubspec.yaml"
  dependencies:
    twitter_login: ^4.0.1
  ```

  Make sure to carefully go through the configuration steps of [`twitter_login`](https://pub.dev/packages/twitter_login) and register a callback URL at the [Twitter Developer Portal](https://developer.twitter.com/) with a matching URL scheme

  ```dart
  import 'package:twitter_login/twitter_login.dart';

  Future<UserCredential> signInWithTwitter() async {
    // Create a TwitterLogin instance
    final twitterLogin = new TwitterLogin(
      apiKey: '<your consumer key>',
      apiSecretKey:' <your consumer secret>',
      redirectURI: '<your_scheme>://'
    );

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
  }
  ```

* {Web}

  On the web, the Twitter SDK provides support for automatically handling the authentication flow using the
  Twitter application details provided on the Firebase console. Ensure that the callback URL in the Firebase console is added
  as a callback URL in your Twitter application on their developer console.

  For example:

  Create a Twitter provider and provide the credential to the `signInWithPopup` method. This will trigger a new
  window to appear prompting the user to sign-in to your Twitter application:

  ```dart
  Future<UserCredential> signInWithTwitter() async {
    // Create a new provider
    TwitterAuthProvider twitterProvider = TwitterAuthProvider();


    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(twitterProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(twitterProvider);
  }
  ```


## GitHub

Ensure that you have setup an OAuth App from your [GitHub Developer Settings](https://github.com/settings/developers) and
that the "GitHub" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers)
with the Client ID and Secret are set, with the callback URL set in the GitHub app.

* {iOS+ and Android}

  On native platforms, a 3rd party library is required to both install the GitHub SDK and trigger the authentication flow.

  Install the [`github_sign_in`](https://pub.dev/packages/github_sign_in) plugin:

  ```yaml title="pubspec.yaml"
  dependencies:
    github_sign_in: ^0.0.5-dev.4
  ```

  You will need to populate the `GitHubSignIn` instance with your GitHub Client ID, GitHub Client Secret and also a Redirect URL (Firebase callback url).
  Once complete trigger the sign-in flow, create a GitHub credential and sign the user in:

  ```dart
  import 'package:github_sign_in/github_sign_in.dart';

  Future<UserCredential> signInWithGitHub() async {
    // Create a GitHubSignIn instance
        final GitHubSignIn gitHubSignIn = GitHubSignIn(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectUrl: 'https://my-project.firebaseapp.com/__/auth/handler');

    // Trigger the sign-in flow
    final result = await gitHubSignIn.signIn(context);

    // Create a credential from the access token
    final githubAuthCredential = GithubAuthProvider.credential(result.token);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(githubAuthCredential);
  }
  ```

* {Web}

  On the web, the GitHub SDK provides support for automatically handling the authentication flow using the
  GitHub application details provided on the Firebase console. Ensure that the callback URL in the Firebase console is added
  as a callback URL in your GitHub application on the developer console.

  For example:

  Create a GitHub provider and provide the credential to the `signInWithPopup` method. This will trigger a new
  window to appear prompting the user to sign-in to your GitHub application:

  ```dart
  Future<UserCredential> signInWithGitHub() async {
    // Create a new provider
    GithubAuthProvider githubProvider = GithubAuthProvider();

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(githubProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(githubProvider);
  }
  ```
