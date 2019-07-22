import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget  {

  @override
  Widget build(BuildContext inContext) {
    return MaterialApp(home : Scaffold(
      floatingActionButton : FloatingActionButton(
        backgroundColor : Colors.red,
        foregroundColor : Colors.yellow,
        child : Icon(Icons.add),
        onPressed : () { print("Ouch! Stop it!"); }
      ),
      body : Center(child : Text("Click it!"))

    ));
  }

}

