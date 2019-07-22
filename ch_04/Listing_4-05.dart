import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget  {

  @override
  Widget build(BuildContext inContext) {
    return MaterialApp(home : Scaffold(
      body : ListView(
        children : [
          ListTile(leading : Icon(Icons.gif), title : Text("1")),
          ListTile(leading : Icon(Icons.book), title : Text("2")),
          ListTile(leading : Icon(Icons.call), title : Text("3")),
          ListTile(leading : Icon(Icons.dns), title : Text("4")),
          ListTile(leading : Icon(Icons.cake), title : Text("5")),
          ListTile(leading : Icon(Icons.pets), title : Text("6")),
          ListTile(leading : Icon(Icons.poll), title : Text("7")),
          ListTile(leading : Icon(Icons.face), title : Text("8")),
          ListTile(leading : Icon(Icons.home), title : Text("9")),
          ListTile(leading : Icon(Icons.adb), title : Text("10")),
          ListTile(leading : Icon(Icons.dvr), title : Text("11")),
          ListTile(leading : Icon(Icons.hd), title : Text("12")),
          ListTile(leading : Icon(Icons.toc), title : Text("3")),
          ListTile(leading : Icon(Icons.tv), title : Text("14")),
          ListTile(leading : Icon(Icons.help), title : Text("15"))
        ]
      )
    ));
  }

}
