import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget  {

  @override
  Widget build(BuildContext inContext) {
    return MaterialApp(home : Scaffold(
      body : Center(child :
        PopupMenuButton(
          onSelected : (String result) { print(result); },
          itemBuilder : (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem(value : "copy", child : Text("Copy")),
            PopupMenuItem(value : "cut", child : Text("Cut")),
            PopupMenuItem(value : "paste", child : Text("Paste"))
          ]
        )
      )

    ));
  }

}
