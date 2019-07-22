import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show FlutterChatModel, model;
import "AppDrawer.dart";
import "Connector.dart" as connector;


class CreateRoom extends StatefulWidget {
 CreateRoom({Key key}) : super(key : key);
 @override
 _CreateRoom createState() => _CreateRoom();
}


class _CreateRoom extends State {


  // State variables.
  String _title;
  String _description;
  bool _private = false;
  double _maxPeople = 25;


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(final BuildContext inContext) {

    print("## CreateRoom.build()");

    return ScopedModel<FlutterChatModel>(model : model, child : ScopedModelDescendant<FlutterChatModel>(
      builder : (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return Scaffold(
          resizeToAvoidBottomPadding : false, // Avoid problem of keyboard causing form fields to vanish.
          appBar : AppBar(title : Text("Create Room")),
          drawer : AppDrawer(),
          bottomNavigationBar : Padding(
            padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
            child : SingleChildScrollView(child : Row(
              children : [
                FlatButton(
                  child : Text("Cancel"),
                  onPressed : () {
                    // Hide soft keyboard.
                    FocusScope.of(inContext).requestFocus(FocusNode());
                    // Navigate back from this screen.
                    Navigator.of(inContext).pop();
                  }
                ),
                Spacer(),
                FlatButton(
                  child : Text("Save"),
                  onPressed : () {
                    // Abort if form isn't valid.
                    if (!_formKey.currentState.validate()) { return; }
                    // Save all the values.
                    _formKey.currentState.save();
                    // Need to truncate maxPeople so we just have an integer.
                    int maxPeople = _maxPeople.truncate();
                    print("_title=$_title, _description = $_description, _maxPeople = $maxPeople, "
                      "_private = $_private, creator = $model.userName"
                    );
                    connector.create(_title, _description, maxPeople, _private, model.userName, (inStatus, inRoomList) {
                      print("## CreateRoom.create: callback: inStatus=$inStatus, inRoomList=$inRoomList");
                      if (inStatus == "created") {
                        // Update the model with the new list of rooms.
                        model.setRoomList(inRoomList);
                        // Hide soft keyboard.
                        FocusScope.of(inContext).requestFocus(FocusNode());
                        // Navigate back from this screen.
                        Navigator.of(inContext).pop();
                      } else {
                        Scaffold.of(inContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Sorry, that room already exists")
                          )
                        );
                      }
                    });
                  } /* End onPressed(). */
                ) /* End FlatButton. */
              ] /* End Row.children. */
            )) /* End SingleChildScrollView. */
          ), /* End bottomNavigationBar. */
          body : Form(
            key : _formKey,
            child : ListView(
              children : [
                // Name.
                ListTile(
                  leading : Icon(Icons.subject),
                  title : TextFormField(decoration : InputDecoration(hintText : "Name"),
                    validator : (String inValue) {
                      if (inValue.length == 0 || inValue.length > 14) {
                        return "Please enter a name no more than 14 characters long";
                      }
                      return null;
                    },
                    onSaved : (String inValue) { setState(() { _title = inValue; }); }
                  )
                ),
                // Description.
                ListTile(
                  leading : Icon(Icons.description),
                  title : TextFormField(decoration : InputDecoration(hintText : "Description"),
                    onSaved : (String inValue) { setState(() { _description = inValue; }); }
                  )
                ),
                // Max People.
                ListTile(
                  title : Row(children : [
                    Text("Max\nPeople"),
                    Slider(min : 0, max : 99, value : _maxPeople,
                      onChanged : (double inValue) { setState(() { _maxPeople = inValue; }); }
                    )
                  ]),
                  trailing : Text(_maxPeople.toStringAsFixed(0))
                ),
                // Private?
                ListTile(
                  title : Row(children : [
                    Text("Private"),
                    Switch(value : _private,
                      onChanged : (inValue) { setState(() { _private = inValue; }); }
                    )
                  ])
                )
              ] /* End Column children. */
            ) /* End ListView. */
          ) /* End Form. */
        ); /* End Scaffold. */
      } /* End ScopedModel.builder(). */
    )); /* End ScopedModel/ScopedModelDescendant. */

  } /* End build(). */


} /* End class. */