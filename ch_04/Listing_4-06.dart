import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget  {

  @override
  Widget build(BuildContext inContext) {
    return MaterialApp(home : Scaffold(
      body : Center(child :
        Chip(
          avatar : CircleAvatar(
            backgroundImage : AssetImage("img/ron.jpg")
          ),
          backgroundColor : Colors.grey.shade300,
          label : Text("Frank Zammetti")
        )
      )

    ));
  }

}

