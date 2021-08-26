import 'package:chat/helperfunctions/sharepref.dart';
import 'package:chat/main.dart';
import 'package:chat/services/database.dart';
import 'package:chat/views/home.dart';
import 'package:chat/views/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Database _dbHelper = Database();

  getCurrentUser() {
    return auth.currentUser;
  }

  // performing the google sign in data
  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? _googleSignInAccount =
        await _googleSignIn.signIn();
    if (_googleSignInAccount != null) {
      final GoogleSignInAuthentication _googleSignInAuth =
          await _googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: _googleSignInAuth.idToken,
          accessToken: _googleSignInAuth.accessToken);
      UserCredential userCredential =
          await auth.signInWithCredential(authCredential);
      User user = userCredential.user!;
      if (authCredential != null) {
        // navigator to homepage
        Prefs dbp = Prefs();
        dbp.saveId(user.uid);
        dbp.saveDisplayName(user.displayName!);
        dbp.saveEmail(user.email!);
        dbp.savePhotoURL(user.photoURL!);
        dbp.saveUsername(user.email!.replaceAll('@gmail.com', ''));
        Map<String, dynamic> userInfo = {
          'id': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'username': user.email!.replaceAll('@gmail.com', '')
        };
        // upload data to firebase
        _dbHelper.addData(userInfo).then((value) => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyApp())));
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    await auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }
}
