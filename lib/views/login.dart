import 'package:chat/services/Auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Auth _auth = Auth();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Center(
          child: ElevatedButton(
              child: Row(
                children: [Icon(Icons.login), Text('Google Login')],
              ),
              onPressed: () {
                _auth.signInWithGoogle(context);
              }),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
            'I will add more method of login nxt time~ FORGIVE ME!!!!!!!!!!!'),
      ),
    );
  }
}
