import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/phone_login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/custom_rounded_button.dart';
import '../logins/google_sign_in.dart';
import 'chat_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FacebookLogin _facebookLogin = FacebookLogin();
FirebaseUser _user;

Future<void> signOut() async {
  await _facebookLogin.logOut();
  await _auth.signOut();
  _user = null;
}

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  bool isRedirected = false;


  //FACEBOOK
  void signInFacebook() async {


    final result = await _facebookLogin.logIn(['email']);
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    print(graphResponse.body);
    if (result.status == FacebookLoginStatus.loggedIn) {
      final credential = FacebookAuthProvider.getCredential(accessToken: token);
      _auth.signInWithCredential(credential);
    }
  }



  @override
  void initState() {
    super.initState();

    // Animation
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: 60.0,
                    ),
                  ),
                  TypewriterAnimatedTextKit(
                    text: ["Flash Chat"],
                    repeatForever: true,
                    textStyle: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 48.0,
              ),
              CustomRoundedButton(
                color: Colors.grey,
                text: 'Log In',
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
              CustomRoundedButton(
                color: Colors.green,
                text: 'Log In With PhoneNumber',
                onPressed: () {
                  Navigator.pushNamed(context, PhoneLoginScreen.id);
                },
              ),
              CustomRoundedButton(
                color: Color(0xFF4c8bf5),
                text: 'Log In With Google',
                onPressed: () {
                  signInWithGoogle().whenComplete(() {
                    isUserInTheFirestore().then((value) {
                      if (value == true) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, ChatScreen.id, (route) => false);
                      } else {
                        Navigator.pushNamed(context, RegistrationScreen.id,
                            arguments: RegistrationScreen.isRedirected = true);
                      }
                    });
                  });
                },
              ),
              CustomRoundedButton(
                color: Color(0xFF3b5998),
                text: 'Log In With Facebook',
                onPressed: () {
                  signInFacebook();
                  isUserInTheFirestore().then((value) {
                    if (value == true) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, ChatScreen.id, (route) => false);
                    } else {
                      Navigator.pushNamed(context, RegistrationScreen.id,
                          arguments: RegistrationScreen.isRedirected = true);
                    }
                  });
                },
              ),
              CustomRoundedButton(
                color: Color(0xFF211F1F),
                text: 'Log In With Github',
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
              CustomRoundedButton(
                color: Color(0xFFF57C00),
                text: 'Register',
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
