import 'package:flutter/material.dart';
import 'package:scholar_chat/models/message.dart';

class ChatBuble extends StatelessWidget {
  const ChatBuble({
    Key? key,
    required this.message,
  }) : super(key: key);
final Message message ;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          top: 16,
          bottom: 16,
          right: 16,
        ),
        margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          color: Colors.blue,
        ),
        child: Text(
          message.message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ChatBubleForFriend extends StatelessWidget {
  const ChatBubleForFriend({
    Key? key,
    required this.message,
  }) : super(key: key);
final Message message ;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          top: 16,
          bottom: 16,
          right: 16,
        ),
        margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomLeft: Radius.circular(32),
          ),
          color: Colors.green,
        ),
        child: Text(
          message.message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}