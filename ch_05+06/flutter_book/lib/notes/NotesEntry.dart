import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "NotesDBWorker.dart";
import "NotesModel.dart" show NotesModel, notesModel;


/// ****************************************************************************
/// The Notes Entry sub-screen.
/// ****************************************************************************
class NotesEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// Constructor.
  NotesEntry() {

    print("## NotesEntry.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## NotesEntry.build()");

    // Set value of controllers.
    _titleEditingController.text = notesModel.entityBeingEdited.title;
    _contentEditingController.text = notesModel.entityBeingEdited.content;

    // Return widget.
    return ScopedModel(
      model : notesModel,
      child : ScopedModelDescendant<NotesModel>(
        builder : (BuildContext inContext, Widget inChild, NotesModel inModel) {
          return Scaffold(
            bottomNavigationBar : Padding(
              padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
              child : Row(
                children : [
                  FlatButton(
                    child : Text("Cancel"),
                    onPressed : () {
                      // Hide soft keyboard.
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      // Go back to the list view.
                      inModel.setStackIndex(0);
                    }
                  ),
                  Spacer(),
                  FlatButton(
                    child : Text("Save"),
                    onPressed : () { _save(inContext, notesModel); }
                  )
                ]
              )
            ),
            body : Form(
              key : _formKey,
              child : ListView(
                children : [
                  // Title.
                  ListTile(
                    leading : Icon(Icons.title),
                    title : TextFormField(
                      decoration : InputDecoration(hintText : "Title"),
                      controller : _titleEditingController,
                      validator : (String inValue) {
                        if (inValue.length == 0) { return "Please enter a title"; }
                        return null;
                      }
                    )
                  ),
                  // Content.
                  ListTile(
                    leading : Icon(Icons.content_paste),
                    title : TextFormField(
                      keyboardType : TextInputType.multiline, maxLines : 8,
                      decoration : InputDecoration(hintText : "Content"),
                      controller : _contentEditingController,
                      validator : (String inValue) {
                        if (inValue.length == 0) { return "Please enter content"; }
                        return null;
                      }
                    )
                  ),
                  // Note color.
                  ListTile(
                    leading : Icon(Icons.color_lens),
                    title : Row(
                      children : [
                        GestureDetector(
                          child : Container(
                            decoration : ShapeDecoration(shape :
                              Border.all(color : Colors.red, width : 18) +
                              Border.all(
                                width : 6,
                                color : notesModel.color == "red" ? Colors.red : Theme.of(inContext).canvasColor
                              )
                            )
                          ),
                          onTap : () {
                            notesModel.entityBeingEdited.color = "red";
                            notesModel.setColor("red");
                          }
                        ),
                        Spacer(),
                        GestureDetector(
                          child : Container(
                            decoration : ShapeDecoration(shape :
                              Border.all(color : Colors.green, width : 18) +
                              Border.all(
                                width : 6,
                                color : notesModel.color == "green" ? Colors.green : Theme.of(inContext).canvasColor
                              )
                            )
                          ),
                          onTap : () {
                            notesModel.entityBeingEdited.color = "green";
                            notesModel.setColor("green");
                          }
                        ),
                        Spacer(),
                        GestureDetector(
                          child : Container(
                            decoration : ShapeDecoration(shape :
                              Border.all(color : Colors.blue, width : 18) +
                              Border.all(
                                width : 6,
                                color : notesModel.color == "blue" ? Colors.blue : Theme.of(inContext).canvasColor
                              )
                            )
                          ),
                          onTap : () {
                            notesModel.entityBeingEdited.color = "blue";
                            notesModel.setColor("blue");
                          }
                        ),
                        Spacer(),
                        GestureDetector(
                          child : Container(
                            decoration : ShapeDecoration(shape :
                              Border.all(color : Colors.yellow, width : 18) +
                              Border.all(
                                width : 6,
                                color : notesModel.color == "yellow" ? Colors.yellow : Theme.of(inContext).canvasColor
                              )
                            )
                          ),
                          onTap : () {
                            notesModel.entityBeingEdited.color = "yellow";
                            notesModel.setColor("yellow");
                          }
                        ),
                        Spacer(),
                        GestureDetector(
                          child : Container(
                            decoration : ShapeDecoration(shape :
                              Border.all(color : Colors.grey, width : 18) +
                              Border.all(
                                width : 6,
                                color : notesModel.color == "grey" ? Colors.grey : Theme.of(inContext).canvasColor
                              )
                            )
                          ),
                          onTap : () {
                            notesModel.entityBeingEdited.color = "grey";
                            notesModel.setColor("grey");
                          }
                        ),
                        Spacer(),
                        GestureDetector(
                          child : Container(
                            decoration : ShapeDecoration(shape :
                              Border.all(color : Colors.purple, width : 18) +
                              Border.all(
                                width : 6,
                                color : notesModel.color == "purple" ? Colors.purple : Theme.of(inContext).canvasColor
                              )
                            )
                          ),
                          onTap : () {
                            notesModel.entityBeingEdited.color = "purple";
                            notesModel.setColor("purple");
                          }
                        )
                      ]
                    )
                  )
                ] /* End Column children. */
              ) /* End ListView. */
            ) /* End Form. */
          ); /* End Scaffold. */
        } /* End ScopedModelDescendant builder(). */
      ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _save(BuildContext inContext, NotesModel inModel) async {

    print("## NotesEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState.validate()) { return; }

    // Creating a new note.
    if (inModel.entityBeingEdited.id == null) {

      print("## NotesEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);

    // Updating an existing note.
    } else {

      print("## NotesEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);

    }

    // Reload data from database to update list.
    notesModel.loadData("notes", NotesDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    Scaffold.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor : Colors.green,
        duration : Duration(seconds : 2),
        content : Text("Note saved")
      )
    );

  } /* End _save(). */


} /* End class. */
