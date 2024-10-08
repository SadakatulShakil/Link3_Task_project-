import 'package:flutter/material.dart';
import 'dart:async';

import '../todo_list_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/toDo_icon.png', width: 150, height: 150,),
          Image.asset('assets/images/toDo_text.png', width: 400, height: 30),
        ],
      ),
    );
  }
}
