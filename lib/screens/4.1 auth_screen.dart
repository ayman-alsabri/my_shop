import 'dart:math';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/auth.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.9),
                  theme.colorScheme.onPrimary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.colorScheme.onPrimary,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _constrainsAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeIn));
    _constrainsAnimation = Tween<double>(begin: 0, end: 70).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    super.initState();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }
    _formKey.currentState!.save();
    FocusManager.instance.primaryFocus!.unfocus();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).logIn(
            _authData['email'] as String, _authData['password'] as String);
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
            _authData['email'] as String, _authData['password'] as String);
      }
    } catch (error) {
      var errorMessage = 'Authentication failed please try again later';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('INVALID_LOGIN_CREDENTIALS')) {
        errorMessage = 'Invalid email or password.';
      } else if (error.toString().contains(
          'OS Error: No address associated with hostname, errno = 7')) {
        errorMessage = 'no internet connection';
      }

      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      _animationController.forward();
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      _animationController.reverse();
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _authMode == AuthMode.signup ? 320 : 260,
          constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.signup ? 320 : 260,
          ),
          width: deviceSize.width * 0.75,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: _autovalidateMode,
            key: _formKey,
            child: Column(
              
              children: <Widget>[
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'E-Mail',
                      constraints:
                          BoxConstraints(minHeight: 40, maxHeight: 70)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value as String;
                  },
                ),
                TextFormField(
                  textInputAction: _authMode==AuthMode.signup? TextInputAction.next: TextInputAction.done,
                  onEditingComplete:_authMode==AuthMode.signup?null:_submit,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      constraints:
                          BoxConstraints(minHeight: 40, maxHeight: 70)),
                  obscureText: true,
                  controller: _passwordController,
                  
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                  },
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => SlideTransition(
                    position: _slideAnimation,
                    child: SizedBox(height:  _constrainsAnimation.value ,
                      child: SingleChildScrollView(
                        child: TextFormField(
                                textInputAction: TextInputAction.done,
                                onEditingComplete: _submit,
                                // enabled: _authMode == AuthMode.signup,
                                decoration:const InputDecoration(
                                  constraints: BoxConstraints(
                                      minHeight: 40,
                                      maxHeight: 70),
                                  labelText: 'Confirm Password',
                                ),
                                obscureText: true,
                                validator: _authMode == AuthMode.signup
                                    ? (value) {
                                        if (value!.isEmpty) {
                                          return 'please confirm password';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match!';
                                        } else {
                                          return null;
                                        }
                                      }
                                    : null,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Flexible(
                    child: TextButton(
                      onPressed: _submit,
                      style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          padding: const MaterialStatePropertyAll(
                            EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 8.0),
                          ),
                          backgroundColor: MaterialStatePropertyAll(
                              theme.colorScheme.onPrimary),
                          textStyle: MaterialStatePropertyAll(TextStyle(
                              color: theme.primaryTextTheme.labelSmall!.color)),
                          elevation: const MaterialStatePropertyAll(8)),
                      child: Text(
                          _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
                    ),
                  ),
                Flexible(
                  child: TextButton(
                    onPressed: _switchAuthMode,
                    style: ButtonStyle(
                        padding: const MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: MaterialStatePropertyAll(
                            TextStyle(color: theme.primaryColor))),
                    child:
                        Text(_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
