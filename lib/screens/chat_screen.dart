import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();


  String text;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
    getMessagesStream();
  }

  void getCurrentUser() async{
    try{
      final user = _auth.currentUser;
      if(user != null){
        loggedInUser = user;
        print(user);
      }
    }catch(e){
    print(e);
    }
  }

  void getMessagesStream() async {
    await for(var snapShots in _fireStore.collection('message').snapshots()){
      for(var message in snapShots.docs){
        print(message.data);
      }
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
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
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
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        text = value;
                      },
                      style: TextStyle(color:Colors.black),
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      _fireStore.collection('message').add({'text':text,'sender':loggedInUser.email});
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

class MessageStream extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(stream: _fireStore.collection('message').snapshots(), builder: (context,snapshot){
      if(!snapshot.hasData){
        return Center(child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent,),);
      }
      final messages = snapshot.data.docs.reversed;
      List<MessageBubble> messageWidgets = [];
      for(var message in messages){
        final messageText = message.get('text');
        final messageSender = message.get('sender');

        final currentUser = loggedInUser.email;

        final messageWidget =MessageBubble(sender: messageSender,text: messageText,isMe:currentUser == messageSender);
        messageWidgets.add(messageWidget);

      }
      return Expanded(child: ListView(padding:EdgeInsets.all(10.0),children: messageWidgets));
    });
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.text,this.sender,this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(color: Colors.black45),),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Material(borderRadius:isMe?BorderRadius.only(topLeft: Radius.circular(20.0),bottomLeft: Radius.circular(20.0),bottomRight: Radius.circular(20.0)):BorderRadius.only(topRight: Radius.circular(20.0),bottomLeft: Radius.circular(20.0),bottomRight: Radius.circular(20.0)),elevation: 5.0,color:isMe?Colors.lightBlueAccent:Colors.white60,child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('$text',style: TextStyle(fontSize: 15.0,color: isMe ?Colors.white: Colors.black45),),
            )),
          ),
        ],
      ),
    );
  }
}
