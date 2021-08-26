import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const String usernameKey = 'USERNAMEKEY';
  static const String emailKey = 'EMAILKEY';
  static const String userIDKey = 'USERIDKEY';
  static const String displayNameKey = 'DISPLAYNAMEKEY';
  static const String photoURLKey = 'PHOTOURLKEY';
  Future<void> saveUsername(String username) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(usernameKey, username);
  }
  Future<void> saveEmail(String email) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(emailKey, email);
  }
  Future<void> saveId(String userID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(userIDKey, userID);
  }
  Future<void> saveDisplayName(String displayName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(displayNameKey, displayName);
  }
  Future<void> savePhotoURL(String photoURL) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(photoURLKey, photoURL);
  }

  Future<String> getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String res = sharedPreferences.getString(usernameKey)!;
    return res;
  }

  Future<String> getEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String res = sharedPreferences.getString(emailKey)!;
    return res;
  }

  Future<String> getId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String res = sharedPreferences.getString(userIDKey)!;
    return res;
  }

  Future<String> getDisplayName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String res = sharedPreferences.getString(displayNameKey)!;
    return res;
  }

   Future<String> getPhotoUrl() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String res = sharedPreferences.getString(photoURLKey)!;
    return res;
  }
}