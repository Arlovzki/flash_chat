import 'package:flutter/material.dart';
import '../components/custom_rounded_button.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'chat_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextFormField(
                    validator: (value) {
                      bool isValid = EmailValidator.validate(value);
                      if (value.isNotEmpty) {
                        if (!isValid) {
                          return 'Invalid email';
                        }
                      } else {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    decoration: kTextFieldDecoration.copyWith(hintText: 'Email')),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                    obscureText: true,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration:
                        kTextFieldDecoration.copyWith(hintText: 'Password')),
                SizedBox(
                  height: 24.0,
                ),
                CustomRoundedButton(
                  text: 'Log In',
                  color: Colors.lightBlueAccent,
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        final newUser = await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                        if (newUser != null) {
                         Navigator.pushNamedAndRemoveUntil(context, ChatScreen.id, (route) => false);
                        }
                      } catch (e) {
                        print(e);
                        Alert(
                          context: context,
                          type: AlertType.error,
                          title: "WRONG CREDENTIALS",
                          desc: "Wrong email or password.",
                        ).show();
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
