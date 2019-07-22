import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home : Scaffold(body : Home()));
  }
}

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext inContext) {

    Future _showIt() async {
      switch (await showDialog(
        context : inContext,
        builder : (BuildContext inContext) {
          return SimpleDialog(
            title : Text("What's your favorite food?"),
            children : [
              SimpleDialogOption(
                onPressed : () {
                  Navigator.pop(inContext, "brocolli");
                },
                child : Text("Brocolli")
              ),
              SimpleDialogOption(
                onPressed : () {
                  Navigator.pop(inContext, "steak");
                },
                child : Text("Steak")
              )
            ]
          );
        }
      )) {
        case "brocolli": print("Brocolli"); break;
        case "steak": print("Steak"); break;
      }
    }

    return Scaffold(
      body : Center(
        child : RaisedButton(
          child : Text("Show it"),
          onPressed : _showIt
        )
      )
    );

  }

}
