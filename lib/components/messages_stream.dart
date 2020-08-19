import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_bubble.dart';

final _firestore = Firestore.instance;

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection('messages').snapshots(),
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

            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,

            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        });
  }
}