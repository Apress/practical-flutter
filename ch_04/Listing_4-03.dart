import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget  {

  Widget build(BuildContext inContext) {
    return MaterialApp(home : Scaffold(
      body : Column(children : [
        Container(height : 100),
          DataTable(sortColumnIndex : 1,
            columns : [
              DataColumn(label : Text("First Name")),
              DataColumn(label : Text("Last Name"))
            ],
            rows : [
              DataRow(cells : [
                DataCell(Text("Leia")),
                DataCell(Text("Organa"), showEditIcon : true)
              ]),
              DataRow(cells : [
                DataCell(Text("Luke")),
                DataCell(Text("Skywalker"))
              ]),
              DataRow(cells : [
                DataCell(Text("Han")),
                DataCell(Text("Solo"))
              ])
            ]
          )
      ])
    ));
  }

}
