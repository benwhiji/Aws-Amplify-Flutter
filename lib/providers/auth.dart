import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/material.dart';
import 'package:login_with_aws/amplifyconfiguration.dart';

class Auth extends ChangeNotifier {
  Amplify amplifyInstance;
  bool isSignUpComplete;
  bool isSignedIn;
  String username;

  Auth() {
    this.amplifyInstance = Amplify();
    configureCognitoPluginWrapper();
  }

  Future<void> configureCognitoPluginWrapper() async {
    await configureCognitoPlugin();
  }

  Future<void> configureCognitoPlugin() async {
    // Add Cognito Plugin
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();

    amplifyInstance.addPlugin(
      authPlugins: [authPlugin],
    );

    // Once Plugins are added, configure Amplify
    await amplifyInstance.configure(amplifyconfig);

    authPlugin.events.listenToAuth((event) {
      print(event);
      switch (event["eventName"]) {
        case "SIGNED_IN":
          print("HUB: USER IS SIGNED IN");
          break;
        case "SIGNED_OUT":
          print("HUB: USER IS SIGNED OUT");
          break;
        case "SESSION_EXPIRED":
          print("HUB: USER SESSION HAS EXPIRED");
          break;
        default:
          print("CONFIGURATION EVENT");
      }
    });
  }

  /// Signup a User
  Future<void> signUp(String username, String password, String email,
      [String phone]) async {
    try {
      Map<String, dynamic> userAttributes = {
        "email": email,
      };

      SignUpResult res = await Amplify.Auth.signUp(
          username: username,
          password: password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));

      isSignUpComplete = res.isSignUpComplete;
    } on AuthError catch (e) {
      print(e.cause);
      print(e.exceptionList.length);

      e.exceptionList.forEach((authException) {
        print(authException.exception);
        print(authException.detail);
      });

      throw (e);
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  /// Confirm User
  Future<void> confirm(String username, String confirmationCode) async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: username, confirmationCode: confirmationCode);

      isSignUpComplete = res.isSignUpComplete;
    } on AuthError catch (e) {
      throw (e);
    } catch (error) {
      throw (error);
    }
  }

  /// Signin a User
  Future<void> signIn(String username, String password) async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
    } on AuthError catch (e) {
      print(e.cause);
      print(e.exceptionList.length);

      e.exceptionList.forEach((authException) {
        print(authException.exception);
        print(authException.detail);
      });

      throw (e);
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<bool> _isSignedIn() async {
    final session = await Amplify.Auth.fetchAuthSession();
    return session.isSignedIn;
  }

  // Sign Out the User.
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut(
          options: CognitoSignOutOptions(globalSignOut: true));
    } on AuthError catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<String> fetchSession() async {
    try {
      CognitoAuthSession session = await Amplify.Auth.fetchAuthSession(
          options: CognitoSessionOptions(getAWSCredentials: true));

      print('Access key: ${session.credentials.awsAccessKey}');
      print('Secret Key: ${session.credentials.awsSecretKey}');
      print('Identity ID:  ${session.identityId}');
      print('User Pool tokens: ${session.userPoolTokens.accessToken}');
      print('User Pool tokens: ${session.userPoolTokens.idToken}');

      return session.isSignedIn.toString();
    } on AuthError catch (e) {
      print(e);
    }
  }

  Future<String> getCurrentUser() async {
    try {
      AuthUser res = await Amplify.Auth.getCurrentUser();
      return res.username;
    } on AuthError catch (e) {
      print(e);
      throw (e);
    }
  }
}
