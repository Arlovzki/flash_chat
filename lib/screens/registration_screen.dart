import 'dart:math';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/material.dart';
import '../components/custom_rounded_button.dart';
import '../constants.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  static bool isRedirected;
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  final _firestore = Firestore.instance;
  var maskFormatter = new MaskTextInputFormatter(
      mask: '###########', filter: {"#": RegExp(r'[0-9]')});

  bool showSpinner = false;
  String name;
  String phoneNumber;
  String email;
  String password;
  String confirmPassword;


  final _formKey = GlobalKey<FormState>();
  final globalKey = GlobalKey<ScaffoldState>();

  Future<void> checkUserWithEmail() async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        showSpinner = false;
      });
      return Alert(
        context: context,
        type: AlertType.error,
        title: "DUPLICATE Account",
        desc: "Email/Credentials is already in use.",
      ).show();
    } catch (e) {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (newUser != null) {
        Navigator.pushNamedAndRemoveUntil(
            context, ChatScreen.id, (route) => false);
      }

      _firestore.collection('users').add({
        'uid': newUser.user.uid,
        'name': name,
        'phoneNumber': phoneNumber,
        'email': newUser.user.email,
        'createdAt': new DateTime.now()
      });
    }

  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }


  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        try{
          loggedInUser =  await user;
        }catch(e){
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
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
                      if (value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      name = value;
                    },
                    decoration:
                        kTextFieldDecoration.copyWith(hintText:  'Name')),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    inputFormatters: [],
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                        hintText:  'Phone Number')),
                SizedBox(
                  height: 8.0,
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
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email =  value;
                    },
                    decoration:
                        kTextFieldDecoration.copyWith(hintText: 'Email')),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                    validator: (value) {
                      if (value.length < 6) {
                        return 'Minimum 6 characters in password';
                      }
                      return null;
                    },
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration:
                        kTextFieldDecoration.copyWith(hintText: 'Password')),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                    validator: (value) {
                      if (value.isNotEmpty) {
                        if (value != password) {
                          return 'Passwords didn\'t match';
                        }
                      } else {
                        return 'Enter a confirmation password';
                      }
                      return null;
                    },
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value) {
                      confirmPassword = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Confirm Password')),
                SizedBox(
                  height: 24.0,
                ),
                CustomRoundedButton(
                  text: 'Register',
                  color: Colors.blueAccent,
                  onPressed: () async {

                    if (_formKey.currentState.validate()) {
                      final snackBar =
                          SnackBar(content: Text('Processing Data!'));
                      globalKey.currentState.showSnackBar(snackBar);
                      setState(() {
                        showSpinner = true;
                      });
                      if(RegistrationScreen.isRedirected == true) {
                        _firestore.collection('users').add({
                          'uid': loggedInUser.uid,
                          'name': name,
                          'phoneNumber': phoneNumber,
                          'email': loggedInUser.email,
                          'createdAt': new DateTime.now()
                        });
                        Navigator.pushNamedAndRemoveUntil(
                            context, ChatScreen.id, (route) => false);
                      }else {
                        checkUserWithEmail();
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
