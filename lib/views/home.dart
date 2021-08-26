import 'package:chat/helperfunctions/sharepref.dart';
import 'package:chat/services/Auth.dart';
import 'package:chat/services/database.dart';
import 'package:chat/views/chat_room.dart';
import 'package:chat/views/recentChat.dart';
import 'package:chat/views/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isSearching = false;
  TextEditingController _findUser = TextEditingController();
  Stream? _users;
  Stream? _recentChat;
  String? myUsername;
  QuerySnapshot? chatterUsername;

  // final _snackBar =
  //     SnackBar(content: Text('Cant find with a empty content, 达咩达咩'), );

  getUsername() async {
    myUsername = await Prefs().getUsername();
    // print(myUsername);
    // print('^^');
  }

  getChatRoom() async {
    _recentChat = await Database().getChatRoom();
    setState(() {});
  }

  onScreenLaunch() async {
    await getUsername();
    getChatRoom();
  }

  @override
  void initState() {
    super.initState();
    onScreenLaunch();
  }

  Future<void> onSearchClick() async {
    _users = await Database().searchUser(_findUser.text);
  }

  String getChatRoomId(String myUsername, String chatterUsername) {
    if (myUsername.codeUnitAt(0) > chatterUsername.codeUnitAt(0)) {
      return '$myUsername\_$chatterUsername';
    } else {
      return '$chatterUsername\_$myUsername';
    }
  }

  Widget userListInfo(url, displayname, email, username) {
    return TextButton(
      onPressed: () {
        var id = getChatRoomId(myUsername!, username);
        Map<String, dynamic> chatRoomInfo = {
          'users': [myUsername, username]
        };
        Database().checkChatRoomExisted(id, chatRoomInfo);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatRoom(
                      chatterDisplayName: displayname,
                      chatterPhotoUrl: url,
                      chatterUsername: username,
                    )));
      },
      child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Container(
                child: ClipRRect(
                  child: Image.network(url),
                  borderRadius: BorderRadius.circular(30),
                ),
                width: 60,
                height: 60,
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    username,
                    style: TextStyle(fontSize: 15),
                  )
                ],
              )
            ],
          )),
    );
  }

  Widget userList() {
    return StreamBuilder(
        stream: _users,
        builder: (context, AsyncSnapshot snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }

          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot _dc = snapshot.data.docs[index];
                  return userListInfo(_dc['photoURL'], _dc['displayName'],
                      _dc['email'], _dc['username']);
                });
          } else {
            return Center(
              child: Text('There is no such people :('),
            );
          }
        });
  }

  Widget recentChat() {
    return StreamBuilder(
        stream: _recentChat,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot _ds = snapshot.data.docs[index];
                    if (_ds.id
                            .replaceAll(myUsername!, '')
                            .replaceAll('_', '') ==
                        '') {
                      // talking to myself

                      return RecentChat(
                          chatterName: myUsername!,
                          lastChat: _ds['lastMessage']);
                    } else {
                      return RecentChat(
                          chatterName: _ds.id
                              .replaceAll(myUsername!, '')
                              .replaceAll('_', ''),
                          lastChat: _ds['lastMessage']);
                    }
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget recentChatUser(src, lasMsg) {
    return Row(
      children: [
        Image.network(src),
        Column(
          children: [Text(''), Text(lasMsg)],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          GestureDetector(
              onTap: () => Auth().signOut(context), child: Icon(Icons.logout))
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  _isSearching == true
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearching = false;
                            });
                            _findUser.text = '';
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Icon(Icons.arrow_back),
                          ),
                        )
                      : SizedBox(),
                  Container(
                    child: Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(24)),
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _findUser,
                                onChanged: (value) {},
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    hintText: 'Find User Here',
                                    border: InputBorder.none),
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  if (_findUser.text.trim().length == 0) {
                                    // the find text field is null and user trying to find
                                    // ScaffoldMessenger.of(context)
                                    //     .showSnackBar(_snackBar);
                                    showTopSnackBar(
                                      context,
                                      CustomSnackBar.error(
                                        textStyle: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                        backgroundColor: Colors.grey,
                                        message: 'Cant find with empty content',
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _isSearching = true;
                                    });
                                    onSearchClick();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.search),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _isSearching
                  ? userList()
                  : Container(
                      child: Expanded(
                        child: ListView(children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Column(
                                children: [
                                  Expanded(child: recentChat()),
                                ],
                              )),
                        ]),
                      ),
                    )
            ],
          )),
    );
  }
}
