import 'package:flutter/material.dart';
import 'package:scholar_chat/constants.dart';
import 'package:scholar_chat/models/message.dart';
import 'package:scholar_chat/widgets/chat_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key}) : super(key: key);
  TextEditingController controller = TextEditingController();
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');
  final _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
  var email =   ModalRoute.of(context)!.settings.arguments;
    return StreamBuilder<QuerySnapshot>(
      stream: messages.orderBy('createdAt',descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Message> messagesList = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            messagesList.add(Message.fromJson(snapshot.data!.docs[i]));
          }
          return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Our Chat',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                centerTitle: true,
                backgroundColor: kPrimaryColor,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                        controller: _controller,
                        itemCount: messagesList.length,
                        itemBuilder: ((context, index) {
                          return messagesList[index].id == email ? ChatBuble(
                            message: messagesList[index],
                          ):ChatBubleForFriend(message: messagesList[index] );
                        })),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: controller,
                      onSubmitted: (data) {
                        messages.add({
                          'message': data,
                          'createdAt': DateTime.now(),
                          'id':email,

                        });
                        controller.clear();
                        _controller.animateTo(
                            0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn);
                      },
                      decoration: InputDecoration(
                          hintText: 'Send Message',
                          suffixIcon: Icon(
                            Icons.send,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ))),
                    ),
                  )
                ],
              ));
        } else {
          return Text('loading...');
        }
      },
    );
  }
}
