import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset('assets/dash.png'),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Sign-In again'),
              onTap: (){
                Navigator.pushNamed(context, '/auth_gate');
              },)
          ],
        ),
      ),
    );
  }
}