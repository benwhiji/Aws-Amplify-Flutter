import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:login_with_aws/providers/auth.dart';
import 'package:login_with_aws/screens/home_page.dart';
import 'package:login_with_aws/widgets/signin_button.dart';
import 'package:login_with_aws/widgets/teddy_controller.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Login, ConfirmUser }

class AuthScreen extends StatefulWidget {
  AuthScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TeddyController _teddyController;
  final _passwordFocusNode = FocusNode();
  bool _showSpinner = false;

  // Default screen is Login mode.
  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
    'confimationCode': '',
  };

  @override
  initState() {
    _teddyController = TeddyController();
    _passwordFocusNode.addListener(_teddyOffPasswordField);
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.removeListener(_teddyOffPasswordField);
    super.dispose();
  }

  // When the focus goes out of password field, Teddy can open his eyes.
  void _teddyOffPasswordField() {
    if (!_passwordFocusNode.hasFocus) {
      _teddyController.coverEyes(false);
    } else {
      _teddyController.coverEyes(true);
      _teddyController.lookAt(null);
    }
  }

  // Alert Dialog to show any error messages.
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void clearCache() {
    _authData['username'] = '';
    _authData['password'] = '';
    _authData['email'] = '';
    _authData['confimationCode'] = '';
  }

  // Sign Up functionality
  Future<void> _signUp() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    // Fills "_authData" map with Signup details.
    _formKey.currentState.save();

    try {
      await Provider.of<Auth>(context, listen: false).signUp(
        _authData['username'],
        _authData['password'],
        _authData['email'],
      );

      // When a user is created in Cognito, he will need to be confirmed. An
      // auth code would have been sent to the user's email. Allow user
      // to enter confirmation code.
      setState(() {
        clearCache();
        _authMode = AuthMode.ConfirmUser;
      });
    } on AuthError catch (e) {
      var message = '';

      e.exceptionList
          .where((authException) =>
              authException.exception != 'PLATFORM_EXCEPTIONS')
          .forEach((authException) {
        message += authException.detail;
      });
      _showDialog(message);
    } catch (error) {
      var message = "Could not be Authenticated. Try later!";
      _showDialog(message);
    }
  }

  // Confirm User by entering his Confirmation Code
  Future<void> _confirmUser() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    try {
      await Provider.of<Auth>(context, listen: false).confirm(
        _authData['username'],
        _authData['confimationCode'],
      );

      // Once the User is confirmed, he can authenticate using his User name
      // and Password.
      setState(() {
        _authMode = AuthMode.Login;
      });
    } on AuthError catch (e) {
      var message = '';

      e.exceptionList
          .where((authException) =>
              authException.exception != 'PLATFORM_EXCEPTIONS')
          .forEach((authException) {
        message += authException.detail;
      });
      _showDialog(message);
    } catch (error) {
      var message = "Could not be Authenticated. Try later!";
      _showDialog(message);
    }
  }

  Future<void> _signIn() async {
    final auth = Provider.of<Auth>(context, listen: false);

    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    try {
      setState(() {
        _showSpinner = true;
      });

      await auth.signIn(
        _authData['username'],
        _authData['password'],
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => HomePage()));
    } on AuthError catch (e) {
      var message = '';

      e.exceptionList
          .where((authException) =>
              authException.exception != 'PLATFORM_EXCEPTIONS')
          .forEach((authException) {
        message += authException.detail;
      });

      _showDialog(message);

      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Color.fromRGBO(93, 142, 155, 1.0),
      body: _showSpinner
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ))
          : Container(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [0.0, 1.0],
                          colors: [
                            Color.fromRGBO(170, 207, 211, 1.0),
                            Color.fromRGBO(93, 142, 155, 1.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          top: devicePadding.top + 50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 200,
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: FlareActor(
                              "assets/flare/Teddy.flr",
                              shouldClip: false,
                              alignment: Alignment.bottomCenter,
                              fit: BoxFit.contain,
                              controller: _teddyController,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15.0),
                                      child: TextFormField(
                                        key: Key('Username'),
                                        initialValue: _authData['username'],
                                        decoration: InputDecoration(
                                          hintText: 'User name',
                                          labelText: 'User name',
                                        ),
                                        textInputAction: TextInputAction.next,
                                        onSaved: (value) {
                                          _authData['username'] = value;
                                        },
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return "Please provide a value!";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    if (_authMode == AuthMode.Signup)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: TextFormField(
                                          key: Key('email'),
                                          initialValue: _authData['email'],
                                          decoration: InputDecoration(
                                            hintText:
                                                "What's your email address?",
                                            labelText: 'Email',
                                          ),
                                          textInputAction: TextInputAction.next,
                                          onSaved: (value) {
                                            _authData['email'] = value;
                                          },
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Please provide a value!";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    if (_authMode == AuthMode.Signup ||
                                        _authMode == AuthMode.Login)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: TextFormField(
                                          key: Key('password'),
                                          initialValue: '',
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            hintText: "Enter password",
                                            labelText: 'Password',
                                          ),
                                          textInputAction: TextInputAction.next,
                                          onSaved: (value) {
                                            _authData['password'] = value;
                                          },
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Please provide a value!";
                                            }
                                            return null;
                                          },
                                          focusNode: _passwordFocusNode,
                                        ),
                                      ),
                                    if (_authMode == AuthMode.ConfirmUser)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20.0),
                                        child: TextFormField(
                                          key: Key('confimationCode'),
                                          initialValue:
                                              _authData['confimationCode'],
                                          decoration: InputDecoration(
                                            hintText: 'Confirmation Code',
                                            labelText: 'Confirmation Code',
                                          ),
                                          textInputAction: TextInputAction.next,
                                          onSaved: (value) {
                                            _authData['confimationCode'] =
                                                value;
                                          },
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Please provide a value!";
                                            }

                                            _teddyController.coverEyes(false);
                                            return null;
                                          },
                                        ),
                                      ),
                                    // When the mode is "Login", show "SignIn" button.
                                    // Show "SignUp" and "Confirm User" below.
                                    if (_authMode == AuthMode.Login)
                                      Column(
                                        children: [
                                          SigninButton(
                                            child: Text(
                                              "Sign In",
                                              style: TextStyle(
                                                  fontFamily: "RobotoMedium",
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              await _signIn();
                                            },
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              FlatButton(
                                                child: Text(
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 16,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    clearCache();
                                                    _teddyController
                                                        .coverEyes(false);
                                                    _authMode = AuthMode.Signup;
                                                  });
                                                },
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  setState(() {
                                                    clearCache();
                                                    _teddyController
                                                        .coverEyes(false);
                                                    _authMode =
                                                        AuthMode.ConfirmUser;
                                                  });
                                                },
                                                child: Text(
                                                  'Confirm User',
                                                  style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 16,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    if (_authMode == AuthMode.Signup)
                                      Column(
                                        children: [
                                          SigninButton(
                                            child: Text(
                                              "Sign Up",
                                              style: TextStyle(
                                                  fontFamily: "RobotoMedium",
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            onPressed: _signUp,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              FlatButton(
                                                child: Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 16,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    clearCache();
                                                    _teddyController
                                                        .coverEyes(false);
                                                    _authMode = AuthMode.Login;
                                                  });
                                                },
                                              ),
                                              FlatButton(
                                                child: Text(
                                                  'Confirm User',
                                                  style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 16,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    clearCache();
                                                    _teddyController
                                                        .coverEyes(false);
                                                    _authMode =
                                                        AuthMode.ConfirmUser;
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    if (_authMode == AuthMode.ConfirmUser)
                                      Column(
                                        children: [
                                          SigninButton(
                                            child: Text(
                                              "Confirm User",
                                              style: TextStyle(
                                                  fontFamily: "RobotoMedium",
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            onPressed: _confirmUser,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              FlatButton(
                                                child: Text(
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 16,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    clearCache();
                                                    _teddyController
                                                        .coverEyes(false);
                                                    _authMode = AuthMode.Signup;
                                                  });
                                                },
                                              ),
                                              FlatButton(
                                                child: Text(
                                                  'Confirm User',
                                                  style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 16,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(
                                                    () {
                                                      clearCache();
                                                      _teddyController
                                                          .coverEyes(false);
                                                      _authMode =
                                                          AuthMode.ConfirmUser;
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
