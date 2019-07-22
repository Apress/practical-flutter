import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home : DefaultTabController(
        length : 3,
        child : Scaffold(
          appBar : AppBar(title : Text("Flutter Playground"),
            bottom : TabBar(
              tabs : [
                Tab(icon : Icon(Icons.announcement)),
                Tab(icon : Icon(Icons.cake)),
                Tab(icon : Icon(Icons.cloud))
              ]
            )
          ),
          body : TabBarView(
            children : [
              Center(child : Text("Announcements")),
              Center(child : Text("Birthdays")),
              Center(child : Text("Data"))
            ]
          )
        )
      )
    );

  }

}
