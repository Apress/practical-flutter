import "dart:io";
import "package:path/path.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show FlutterChatModel, model;
import "Connector.dart" as connector;


// ignore: must_be_immutable
class LoginDialog extends StatelessWidget {


  // Key of the login form.  Note it has to be static final so that it doesn't get recreated multiple times
  // to avoid the keyboard popping up and disappearing (see here: https://github.com/flutter/flutter/issues/20042).
  static final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();

  // UserName that the user enters.
  String _userName;


  // Password that the user enters.
  String _password;


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(final BuildContext inContext) {

    print("## LoginDialog.build()");

    return ScopedModel<FlutterChatModel>(model : model, child : ScopedModelDescendant<FlutterChatModel>(
      builder : (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return AlertDialog(
          content : Container(height : 220,
            child : Form(key : _loginFormKey,
              child : Column(
                children : [
                  Text("Enter a username and password to register with the server", textAlign : TextAlign.center,
                    style : TextStyle(color : Theme.of(model.rootBuildContext).accentColor, fontSize : 18)
                  ),
                  SizedBox(height : 20),
                  TextFormField(
                    validator : (String inValue) {
                      if (inValue.length == 0 || inValue.length > 10) {
                        return "Please enter a username no more than 10 characters long";
                      }
                      return null;
                    },
                    onSaved : (String inValue) { _userName = inValue; },
                    decoration : InputDecoration(hintText : "Username", labelText : "Username")
                  ),
                  TextFormField(obscureText : true,
                    validator : (String inValue) {
                      if (inValue.length == 0) { return "Please enter a password"; }
                      return null;
                    },
                    onSaved : (String inValue) { _password = inValue; },
                    decoration : InputDecoration(hintText : "Password", labelText : "Password")
                  )
                ] /* End Column children. */
              ) /* End Column. */
            ) /* End Form. */
          ), /* End Container. */
          actions : [
            FlatButton(
              child : Text("Log In"),
              onPressed : () {
                if (_loginFormKey.currentState.validate()) {
                  // The form is valid, save values to accessible variables.
                  _loginFormKey.currentState.save();
                  // Trigger connection to server.
                  connector.connectToServer(() {
                    // Ok, we're connected, now try to validate the user.
                    connector.validate(_userName, _password, (inStatus) async {
                      print("## LoginDialog: validate callback: inResponseStatus = $inStatus");
                      // Existing user logged in.
                      if (inStatus == "ok") {
                        // Store userName in model.
                        model.setUserName(_userName);
                        // Hide login dialog.
                        Navigator.of(model.rootBuildContext).pop();
                        // Show greeting on Home screen.
                        model.setGreeting("Welcome back, $_userName!");
                      // Username is already taken (it COULD mean a bad password, but that SHOULD be impossible).
                      } else if (inStatus == "fail") {
                        // Alert user to the result.
                        Scaffold.of(model.rootBuildContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Sorry, that username is already taken")
                          )
                        );
                      // New user created.
                      } else if (inStatus == "created") {
                        // Write out credentials file.
                        var credentialsFile = File(join(model.docsDir.path, "credentials"));
                        await credentialsFile.writeAsString("$_userName============$_password");
                        // Store userName in model.
                        model.setUserName(_userName);
                        // Hide login dialog.
                        Navigator.of(model.rootBuildContext).pop();
                        // Show greeting on Home screen.
                        model.setGreeting("Welcome to the server, $_userName!");
                      }
                    });
                  });
                } /* End form valid check. */
              } /* End onPressed(). */
            ) /* End FlatButton. */
          ] /* End actions. */
        ); /* End AlertDialog. */
      } /* End ScopedModel.builder(). */
    )); /* End ScopedModel/ScopedModelDescendant. */

  } /* End build(). */


  /// Called when the user has stored credentials.
  ///
  /// @param inUserName The
  void validateWithStoredCredentials(final String inUserName, final String inPassword) {

    print("## LoginDialog.validateWithStoredCredentials(): inUserName = $inUserName, inPassword = $inPassword");

    // Trigger connection to server.
    connector.connectToServer(() {
      // Ok, we're connected, now try to validate the user.
      connector.validate(inUserName, inPassword, (inStatus) {
        print("## LoginDialog: validateWithStoredCredentials callback: inStatus = $inStatus");
        // Existing user logged in (or server restarted and the username was available, which means we get created
        // back, and that should be treated the same as a valid login).
        if (inStatus == "ok" || inStatus == "created") {
          // Store userName in model.
          model.setUserName(inUserName);
          // Show greeting on Home screen.
          model.setGreeting("Welcome back, $inUserName!");
        // If we get a fail back then the only possible cause is the server restarted and the username stored is
        // already taken.  In that case, we'll delete the credentials file and let the user know.
        } else if (inStatus == "fail") {
          // Alert user to the result.
          showDialog(context : model.rootBuildContext, barrierDismissible : false,
            builder : (final BuildContext inDialogContext) => AlertDialog(
              title : Text("Validation failed"),
              content : Text("It appears that the server has restarted and the username you last used was "
                "subsequently taken by someone else.\n\nPlease re-start FlutterChat and choose a different username."
              ),
              actions : [
                FlatButton(child : Text("Ok"), onPressed : () {
                  // Delete the credentials file.
                  var credentialsFile = File(join(model.docsDir.path, "credentials"));
                  credentialsFile.deleteSync();
                  // Exit the app.
                  exit(0);
                })
              ]
            )
          );
        }
      });
    });

  } /* End validateWithStoredCredentials(). */


} /* End class. */
