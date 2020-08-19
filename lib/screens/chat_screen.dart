import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/welcome_screen.dart';
import '../components/message_bubble.dart';
import '../logins/google_sign_in.dart';



final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }


  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Alert(
                  context: context,
                  type: AlertType.warning,
                  title: "Do you want to log out?",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "YES",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
//                        print(_auth.signOut());
                        signOutGoogle();
                        signOut();

                        Navigator.pushNamedAndRemoveUntil(
                            context, WelcomeScreen.id, (route) => false);
                      },
                      color: Color.fromRGBO(0, 179, 134, 1.0),
                    ),
                    DialogButton(
                      child: Text(
                        "NO",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      gradient: LinearGradient(colors: [
                        Color.fromRGBO(116, 116, 191, 1.0),
                        Color.fromRGBO(52, 138, 199, 1.0)
                      ]),
                    )
                  ],
                ).show();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'createdAt': new DateTime.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection('messages').orderBy('createdAt', descending: true).snapshots(),
        // ignore: missing_return
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapShot.data.documents;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];

            final currentUser = loggedInUser.email;

            if (currentUser == messageSender) {}

            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        });
  }
}
