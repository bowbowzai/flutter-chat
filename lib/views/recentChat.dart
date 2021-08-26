import 'package:chat/services/database.dart';
import 'package:chat/views/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecentChat extends StatefulWidget {
  final String chatterName;
  final String lastChat;
  const RecentChat(
      {Key? key, required this.chatterName, required this.lastChat})
      : super(key: key);

  @override
  _RecentChatState createState() => _RecentChatState();
}

class _RecentChatState extends State<RecentChat> {
  QuerySnapshot? _myInfo;
  String? _myName;
  String? _myUrl;
  String? _myDisplayName;
  getMyInfo() async {
    _myInfo = await Database().getUserInfo(widget.chatterName);
    _myName = _myInfo!.docs[0]['username'];
    _myUrl = _myInfo!.docs[0]['photoURL'];
    _myDisplayName = _myInfo!.docs[0]['displayName'];
    setState(() {});
  }

  @override
  void initState() {
    getMyInfo();
    setState(() {});
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _myName != null && _myUrl != null && _myDisplayName != null
        ? TextButton(
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: () {
              if (_myDisplayName != null && _myUrl != null && _myName != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatRoom(
                              chatterDisplayName: _myDisplayName!,
                              chatterPhotoUrl: _myUrl!,
                              chatterUsername: _myName!,
                            )));
              }
            },
            child: Row(
              children: [
                ClipRRect(
                  child: Image.network(
                    _myUrl!,
                    height: 60,
                    width: 60,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _myName!,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      widget.lastChat,
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                )
              ],
            ),
          )
        : Center(
            child: Text('Since like you havent talk to someone..'),
          );
  }
}
