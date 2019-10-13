import "package:flutter/material.dart";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key : key);
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State {

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var _checkboxValue = false;
  var _switchValue = false;
  var _sliderValue = .3;
  var _radioValue = 1;

  @override
  Widget build(BuildContext inContext) {
    return MaterialApp(home : Scaffold(
      body : Container(
        padding : EdgeInsets.all(50.0),
        child : Form(
          key : this._formKey,
          child : Column(
            children : [
              Checkbox(
                value : _checkboxValue,
                onChanged : (bool inValue) {
                  setState(() { _checkboxValue = inValue; });
                }
              ),
              Switch(
                value : _switchValue,
                onChanged : (bool inValue) {
                  setState(() { _switchValue = inValue; });
                }
              ),
              Slider(
                min : 0, max : 20,
                value : _sliderValue,
                onChanged : (inValue) {
                  setState(() => _sliderValue = inValue);
                }
              ),
              Row(children : [
                Radio(value : 1, groupValue : _radioValue,
                  onChanged : (int inValue) {
                    setState(() { _radioValue = inValue; });
                  }
                ),
                Text("Option 1")
              ]),
              Row(children : [
                Radio(value : 2, groupValue : _radioValue,
                  onChanged : (int inValue) {
                    setState(() { _radioValue = inValue; });
                  }
                ),
                Text("Option 2")
              ]),
              Row(children : [
                Radio(value : 3, groupValue : _radioValue,
                  onChanged : (int inValue) {
                    setState(() { _radioValue = inValue; });
                  }
                ),
                Text("Option 3")
              ])
            ]
          )
        )
      )
    ));
  }

}
