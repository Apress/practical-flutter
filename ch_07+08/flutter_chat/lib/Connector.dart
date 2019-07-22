import "dart:convert";
import "package:flutter_socket_io/flutter_socket_io.dart";
import "package:flutter_socket_io/socket_io_manager.dart";
import "Model.dart" show FlutterChatModel, model;
import "package:flutter/material.dart";


// The URL of the server.
String serverURL = "http://192.168.1.32";


// The one and only SocketIO instance.
SocketIO _io;


// ------------------------------ NONE-MESSAGE RELATED METHODS ------------------------------


/// Show the please wait dialog.
void showPleaseWait() {

  print("## Connector.showPleaseWait()");

  showDialog(context : model.rootBuildContext, barrierDismissible : false,
    builder : (BuildContext inDialogContext) {
      return Dialog(
        child : Container(width : 150, height : 150, alignment : AlignmentDirectional.center,
          decoration : BoxDecoration(color : Colors.blue[200]),
          child : Column(crossAxisAlignment : CrossAxisAlignment.center, mainAxisAlignment : MainAxisAlignment.center,
            children : [
              Center(child : SizedBox(height : 50, width : 50,
                child : CircularProgressIndicator(value : null, strokeWidth : 10)
              )),
              Container(margin : EdgeInsets.only(top : 20),
                child : Center(child : Text("Please wait, contacting server...",
                  style : new TextStyle(color : Colors.white)
                ))
              )
            ]
          )
        )
      );
    }
  );

} /* End showPleaseWait(). */


/// Hide the please wait dialog.
void hidePleaseWait() {

  print("## Connector.hidePleaseWait()");

  Navigator.of(model.rootBuildContext).pop();

} /* End hidePleaseWait(). */


/// Connect to the server.  Called once from LoginDialog.
///
/// @param inCallback The function to call when the response comes back.
void connectToServer(final Function inCallback) {

  print("## Connector.connectToServer(): serverURL = $serverURL");

  // Connect to server and when the connect mesage comes back, call the specified callback.
  _io = SocketIOManager().createSocketIO(serverURL, "/", query: "", socketStatusCallback :
    (inData) {
      print("## Connector.connectToServer(): callback: inData = $inData");
      if (inData == "connect") {
        print("## Connector.connectToServer(): callback: Connected to server");
        // Hook up message listeners.
        _io.subscribe("newUser", newUser);
        _io.subscribe("created", created);
        _io.subscribe("closed", closed);
        _io.subscribe("joined", joined);
        _io.subscribe("left", left);
        _io.subscribe("kicked", kicked);
        _io.subscribe("invited", invited);
        _io.subscribe("posted", posted);
        // Call the callback so the app can continue to start up.
        inCallback();
      }
    }
  );

// THIS IS ONLY FOR DEVELOPMENT SO THAT WE GET A FRESH SOCKET AFTER A HOT RELOAD (THE ABOVE CALLBACK WILL NOT HAVE EXECUTED BECAUSE A SOCKET ALREADY EXISTS, BUT WE NEED IT TO, SO THIS EFFECTIVELY FORCES IT)
_io.destroy();
_io = SocketIOManager().createSocketIO(serverURL, "/", query: "", socketStatusCallback :
  (inData) {
    print("## Connector.connectToServer(): callback: inData = $inData");
    if (inData == "connect") {
      print("## Connector.connectToServer(): callback: Connected to server");
      inCallback();
    }
  }
);

  _io.init();
  _io.connect();

} /* End connectToServer(). */


// ------------------------------ MESSAGE SENDER METHODS ------------------------------


/// Validate the user.  Called from LoginDialog when there were no stored credentials for the user.
///
/// @param inUserName The username they entered.
/// @param inPassword The password they entered.
/// @param inCallback The function to call when the response comes back.  Is passed the status.
void validate(final String inUserName, final String inPassword, final Function inCallback) {

  print("## Connector.validate(): inUserName = $inUserName, inPassword = $inPassword");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to validate.
  _io.sendMessage("validate",
    "{ \"userName\" : \"$inUserName\", \"password\" : \"$inPassword\" }",
    (inData) {
      print("## Connector.validate(): callback: inData = $inData");
      // Parse response JSON string into a Map.
      Map<String, dynamic> response = jsonDecode(inData);
      print("## Connector.validate(): callback: response = $response");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback(response["status"]);
    }
  );

} /* End validate(). */


/// Get the current list of rooms on the server.
///
/// @param inCallback The function to call when the response comes back.  Is passed the map of room descriptors.
void listRooms(final Function inCallback) {

  print("## Connector.listRooms()");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("listRooms", "{}",
    (inData) {
      print("## Connector.listRooms(): callback: inData = $inData");
      // Parse response JSON string into a Map.
      Map<String, dynamic> response = jsonDecode(inData);
      print("## Connector.listRooms(): callback: response = $response");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback(response);
    }
  );

} /* End listRooms(). */


/// Create a room.
///
/// @param inRoomName    The name of the room.
/// @param inDescription The description of the room.
/// @param inMaxPeople   The maximum number of people allowed in the room.
/// @param inPrivate     Whether the room is private or not.
/// @param inCreator     The userName of the user creating the room.
/// @param inCallback    The function to call when the response comes back.  Is passed the status and the map of
///                      of room descriptors.
void create(final String inRoomName, final String inDescription, final int inMaxPeople, final bool inPrivate,
  final String inCreator, final Function inCallback
) {

  print("## Connector.create(): inRoomName = $inRoomName, inDescription = $inDescription, "
    "inMaxPeople = $inMaxPeople, inPrivate = $inPrivate, inCreator = $inCreator"
  );

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("create",
    "{ \"roomName\" : \"$inRoomName\", \"description\" : \"$inDescription\", "
    "\"maxPeople\" : $inMaxPeople, \"private\" : $inPrivate, \"creator\" : \"$inCreator\" }",
    (inData) {
      print("## Connector.create(): callback: inData = $inData");
      // Parse response JSON string into a Map.
      Map<String, dynamic> response = jsonDecode(inData);
      print("## Connector.create(): callback: response = $response");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback(response["status"], response["rooms"]);
    }
  );

} /* End create(). */


/// Join a room.
///
/// @param inUserName The user's userName.
/// @param inRoomName The name of the room being joined.
/// @param inCallback The function to call when the response comes back.  Is passed the status and the map of
///                   room descriptor objects.
void join(final String inUserName, final String inRoomName, final Function inCallback) {

  print("## Connector.join(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("join", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\"}",
    (inData) {
      print("## Connector.join(): callback: inData = $inData");
      // Parse response JSON string into a Map.
      Map<String, dynamic> response = jsonDecode(inData);
      print("## Connector.join(): callback: response = $response");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback(response["status"], response["room"]);
    }
  );

} /* End join(). */


/// Leave a room.
///
/// @param inUserName The user's userName.
/// @param inRoomName The name of the room being joined.
/// @param inCallback The function to call when the response comes back.
void leave(final String inUserName, final String inRoomName, final Function inCallback) {

  print("## Connector.leave(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("leave", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\"}",
    (inData) {
      print("## Connector.leave(): callback: inData = $inData");
      // Parse response JSON string into a Map.
      Map<String, dynamic> response = jsonDecode(inData);
      print("## Connector.listUsers(): callback: response = $response");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback();
    }
  );

} /* End leave(). */


/// Get the current list of users on the server.
///
/// @param inCallback The function to call when the response comes back.  Is passed the map of user descriptor
///                   objects.
void listUsers(final Function inCallback) {

  print("## Connector.listUsers()");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("listUsers", "{}",
    (inData) {
      print("## Connector.listUsers(): callback: inData = $inData");
      // Parse response JSON string into a Map.
      Map<String, dynamic> response = jsonDecode(inData);
      print("## Connector.listUsers(): callback: response = $response");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback(response);
    }
  );

} /* End listUsers(). */


/// Invite a user to a room.
///
/// @param inUserName    The name of the user being invited.
/// @param inRoomName    The name of the room being invited to.
/// @param inInviterName The name of the user inviting.
/// @param inCallback    The function to call when the response comes back.
void invite(final String inUserName, final String inRoomName, final String inInviterName, final Function inCallback) {

  print("## Connector.invite(): inUserName = $inUserName, inRoomName = $inRoomName, inInviterName = $inInviterName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("invite", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\", "
    "\"inviterName\" : \"$inInviterName\" }",
    (inData) {
      print("## Connector.invite(): callback: inData = $inData");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback();
    }
  );

} /* End invite(). */


/// Posts a message to a room.
///
/// @param inUserName The name of the user being kicked.
/// @param inRoomName The name of the room being closed.
/// @param inCallback The function to call when the response comes back.
void post(final String inUserName, final String inRoomName, final String inMessage, final Function inCallback) {

  print("## Connector.post(): inUserName = $inUserName, inRoomName = $inRoomName, inMessage = $inMessage");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("post", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\", "
    "\"message\" : \"$inMessage\" }",
    (inData) {
      print("## Connector.post(): callback: inData = $inData");
      // Parse response JSON string into a Map.
      Map<String, dynamic> response = jsonDecode(inData);
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback(response["status"]);
    }
  );

} /* End post(). */


/// Close a room (creator function).
///
/// @param inRoomName The name of the room being closed.
/// @param inCallback The function to call when the response comes back.
void close(final String inRoomName, final Function inCallback) {

  print("## Connector.close(): inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("close", "{ \"roomName\" : \"$inRoomName\" }",
    (inData) {
      print("## Connector.close(): callback: inData = $inData");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback();
    }
  );

} /* End close(). */


/// Kick a user from a room (creator function).
///
/// @param inUserName The name of the user being kicked.
/// @param inRoomName The name of the room being closed.
/// @param inCallback The function to call when the response comes back.
void kick(final String inUserName, final String inRoomName, final Function inCallback) {

  print("## Connector.kick(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("kick", "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\" }",
    (inData) {
      print("## Connector.kick(): callback: inData = $inData");
      // Hide please wait.
      hidePleaseWait();
      // Call the specified callback, passing it the response.
      inCallback();
    }
  );

} /* End kick(). */


// ------------------------------ MESSAGE RECEIVER METHODS ------------------------------


/// Received when a new user is created.  Receives the current list of users on the server.
///
/// @param inData The data sent from the server.
void newUser(inData) {

  print("## Connector.newUser(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.newUser(): payload = $payload");

  model.setUserList(payload);

} /* End newUser(). */


/// Received when a room is created.  Receives the current list of rooms on the server.
///
/// @param inData The data sent from the server.
void created(inData) {

  print("## Connector.created(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.created(): payload = $payload");

  model.setRoomList(payload);

} /* End created(). */


/// Received when a room is closed.  Receives the current list of rooms on the server.
///
/// @param inData The data sent from the server.
void closed(inData) {

  print("## Connector.closed(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.closed(): payload = $payload");

  model.setRoomList(payload);

  // If this user is in the room, boot 'em! (oh, also, be nice and tell 'em what happened).
  if (payload["roomName"] == model.currentRoomName) {
    // Clear the model attributes reflecting the user in this room.
    model.removeRoomInvite(payload["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentRoomEnabled(false);
    // Tell the user the room was closed.
    model.setGreeting("The room you were in was closed by its creator.");
    // Route back to the home screen.
    Navigator.of(model.rootBuildContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
  }

} /* End closed(). */


/// Received when a user joins a room.  Receives the room descriptor.
///
/// @param inData The data sent from the server.
void joined(inData) {

  print("## Connector.joined(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.joined(): payload = $payload");

  // Update the list of users in the room if this user is in the room.
  if (model.currentRoomName == payload["roomName"]) {
    model.setCurrentRoomUserList(payload["users"]);
  }

} /* End joined(). */


/// Received when a user leaves a room.  Receives the room descriptor.
///
/// @param inData The data sent from the server.
void left(inData) {

  print("## Connector.left(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.left(): payload = $payload");

  // Update the list of users in the room if this user is in the room.
  if (model.currentRoomName == payload["room"]["roomName"]) {
    model.setCurrentRoomUserList(payload["room"]["users"]);
  }

} /* End left(). */


/// Received this user is kicked from a room.  Receives the room descriptor.
///
/// @param inData The data sent from the server.
void kicked(inData) {

  print("## Connector.kicked(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.kicked(): payload = $payload");

  // Clear the model attributes reflecting the user in this room.
  model.removeRoomInvite(payload["roomName"]);
  model.setCurrentRoomUserList({});
  model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
  model.setCurrentRoomEnabled(false);

  // Tell the user they got the boot.
  model.setGreeting("What did you do?! You got kicked from the room! D'oh!");

  // Route back to the home screen.
  Navigator.of(model.rootBuildContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));

} /* End kicked(). */


/// Received when the user is invited to a room.  Receives the room name and inviter name (and username, but
/// that's pretty irrelevant to this function).
///
/// @param inData The data sent from the server.
void invited(inData) async {

  print("## Connector.invited(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.invited(): payload = $payload");

  // Grab necessary data from payload.
  String roomName = payload["roomName"];
  String inviterName = payload["inviterName"];

  // Add the invite to the model.
  model.addRoomInvite(roomName);

  // Show snackbar to alert the user about the invite.
  Scaffold.of(model.rootBuildContext).showSnackBar(
    SnackBar(backgroundColor : Colors.amber, duration : Duration(seconds : 60),
      content : Text("You've been invited to the room '$roomName' by user '$inviterName'.\n\n"
        "You can enter the room from the lobby."
      ),
      action : SnackBarAction(
        label : "Ok",
        onPressed: () { }
      )
    )
  );

} /* End invited(). */


/// Received when a posts a message to a room.  Receives an object with roomName, userName and message.
///
/// @param inData The data sent from the server.
void posted(inData) {

  print("## Connector.posted(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.posted(): payload = $payload");

  // If the user is currently in the room then add message to room's message list.
  if (model.currentRoomName == payload["roomName"]) {
    model.addMessage(payload["userName"], payload["message"]);
  }

} /* End posted(). */
