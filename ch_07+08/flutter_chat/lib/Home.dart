import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show FlutterChatModel, model;
import "AppDrawer.dart";


class Home extends StatelessWidget {


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(final BuildContext inContext) {

    print("## Home.build()");

    return ScopedModel<FlutterChatModel>(model : model, child : ScopedModelDescendant<FlutterChatModel>(
      builder : (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return Scaffold(
          appBar : AppBar(title : Text("FlutterChat")),
          drawer : AppDrawer(),
          body : Center(child : Text(model.greeting))
        );
      }
    ));

  } /* End build(). */


} /* End class. */