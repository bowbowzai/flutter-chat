import 'package:chat/helperfunctions/sharepref.dart';
import 'package:chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatRoom extends StatefulWidget {
  final String chatterUsername;
  final String chatterPhotoUrl;
  final String chatterDisplayName;

  const ChatRoom(
      {Key? key,
      required this.chatterUsername,
      required this.chatterPhotoUrl,
      required this.chatterDisplayName})
      : super(key: key);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String? chatroomId;
  String? myUsername;
  String? myDisplayName;
  String? myPhotoUrl;
  String? myEmail;
  TextEditingController _msg = TextEditingController();
  Stream? messages;
  ScrollController controller = new ScrollController();
  // initialize my userinfo
  Future<void> getMyUserInfo() async {
    myUsername = await Prefs().getUsername();
    myDisplayName = await Prefs().getDisplayName();
    myPhotoUrl = await Prefs().getPhotoUrl();
    myEmail = await Prefs().getEmail();
    chatroomId = getChatRoomId(myUsername!, widget.chatterUsername);
  }

  // generate room id
  // cuz chatter and user need to have the same room id
  // so if i use the user_chatter id then it will be opposite in the chatter(chatter_user)
  // so we have to compare the name and get the same room id
  String getChatRoomId(String myUsername, String chatterUsername) {
    if (myUsername.substring(0, 1).codeUnitAt(0) >
        chatterUsername.substring(0, 1).codeUnitAt(0)) {
      return '$myUsername\_$chatterUsername';
    } else {
      return '$chatterUsername\_$myUsername';
    }
  }

  getMessages() async {
    messages = await Database().getMessages(chatroomId);
    setState(() {});
  }

  onLaunch() async {
    await getMyUserInfo();
    await getMessages();
  }

  sendMessage() {
    if (_msg.text.trim().length != 0) {
      var sendTime = DateTime.now();
      String msgID = randomAlphaNumeric(9);
      Map<String, dynamic> _msgInfo = {
        'messageID': msgID,
        'message': _msg.text,
        'sendBy': myUsername,
        'time': sendTime,
        'myphotoUrl': myPhotoUrl,
        'chatterPhotoUrl': widget.chatterPhotoUrl
      };
      // print(widget.chatterUsername);
      // print(myUsername);
      Database().saveMessage(chatroomId, _msgInfo, msgID).then((value) {
        Map<String, dynamic> lastMsg = {
          'lastMsgTime': sendTime,
          'sendBy': myUsername,
          'lastMessage': _msg.text
        };
        Database().updateLastMessage(chatroomId, lastMsg);
        _msg.text = '';
        controller.jumpTo(controller.position.minScrollExtent);
      });
    }
  }

  Widget sgMsg(String msg, bool isMe) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.05,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
              )),
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Container(
            child: Text(
              msg,
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  // this will show the data in the stream by list
  Widget chatHistory() {
    return StreamBuilder(
        stream: messages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  controller: controller,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot _dc = snapshot.data.docs[index];

                    return sgMsg(_dc['message'], _dc['sendBy'] == myUsername);
                  })
              : Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                );
        });
  }

  @override
  void initState() {
    // print(myUsername);
    // print( widget.chatterUsername);
    super.initState();
    onLaunch();
    WidgetsBinding.instance!.addPostFrameCallback(
        (_) => controller.jumpTo(controller.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatterDisplayName),
      ),
      body: Scrollbar(
        thickness: 2.0,
        isAlwaysShown: true,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Stack(children: [
            Container(
              padding: EdgeInsets.only(bottom: 60),
              height: MediaQuery.of(context).size.height * 0.85,
              child: chatHistory(),
            ),
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white.withOpacity(0.2),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: TextField(
                          controller: _msg,
                          style: TextStyle(fontSize: 18),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5),
                              hintText: 'Text your message here',
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: sendMessage,
                      child: Icon(
                        Icons.send,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
