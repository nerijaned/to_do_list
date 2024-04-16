import 'package:flutter/material.dart';
import 'package:to_do_list/screens/my_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_list/firebase_options.dart';

void main() async{

  //Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Initialized Firebase with the current platform's default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage()
    );
  }
}
