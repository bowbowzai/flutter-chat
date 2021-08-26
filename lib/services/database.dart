import 'package:chat/helperfunctions/sharepref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  Future<void> addData(userInfo) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userInfo['id'])
        .set(userInfo);
  }

  Future<Stream> searchUser(String user) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: user)
        .snapshots();
  }

  Future<void> saveMessage(chatRoomId, msgInfo, msgId) async {
    return await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(msgId)
        .set(msgInfo);
  }

  Future<void> updateLastMessage(chatRoomId, lastmsgInfo) async {
    return await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .update(lastmsgInfo);
  }

  Future<dynamic> checkChatRoomExisted(
      String chatRoomId, chatRoomInitInfo) async {
    var document = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .get();
    if (document.exists) {
      // chatroom existed
      return true;
    } else {
      // lets create a chatroom
      FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(chatRoomId)
          .set(chatRoomInitInfo);
    }
  }

  Future<Stream> getMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<Stream> getChatRoom() async {
    String myUsername = await Prefs().getUsername();
    return FirebaseFirestore.instance
        .collection('chatRoom')
        .where('users', arrayContains: myUsername)
        .orderBy('lastMsgTime', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(username) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  Future<void> updateUserDisplayName(newInfoMap) async {
    String id = await Prefs().getId();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update(newInfoMap);
  }
}
