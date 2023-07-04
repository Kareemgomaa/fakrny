import 'package:flutter/material.dart';

class connectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('ربط الساعه ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Fourth Screen'),
      ),
    );
  }
}