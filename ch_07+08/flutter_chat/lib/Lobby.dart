import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show FlutterChatModel, model;
import "AppDrawer.dart";
import "Connector.dart" as connector;


class Lobby extends StatelessWidget {


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(final BuildContext inContext) {

    print("## Lobby.build()");

    return ScopedModel<FlutterChatModel>(model : model, child : ScopedModelDescendant<FlutterChatModel>(
      builder : (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return Scaffold(
          appBar : AppBar(title : Text("Lobby")),
          drawer : AppDrawer(),
          // Add room.
          floatingActionButton : FloatingActionButton(
            child : Icon(Icons.add, color : Colors.white),
            onPressed : () { Navigator.pushNamed(inContext, "/CreateRoom"); }
          ),
          body : model.roomList.length == 0 ? Center(child : Text("There are no rooms yet. Why not add one?")) :
            ListView.builder(
            itemCount : model.roomList.length,
            itemBuilder : (BuildContext inBuildContext, int inIndex) {
              Map room = model.roomList[inIndex];
              String roomName = room["roomName"];
              return Column(
                children : [
                  ListTile(
                    leading : room["private"] ? Image.asset("assets/private.png") : Image.asset("assets/public.png"),
                    title : Text(roomName),
                    subtitle : Text(room["description"]),
                    // Enter room (if not private).
                    onTap : () {
                      // If the room is private and the user doesn't have an invite and they aren't the user that
                      // created the room, then they can't get in.
                      if (room["private"] && !model.roomInvites.containsKey(roomName) &&
                        room["creator"] != model.userName
                      ) {
                        Scaffold.of(inBuildContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Sorry, you can't enter a private room without an invite")
                          )
                        );
                      } else {
                        connector.join(model.userName, roomName, (inStatus, inRoomDescriptor) {
                          print("## Lobby.joined callback: inStatus = $inStatus, inRoomDescriptor = $inRoomDescriptor");
                          if (inStatus == "joined") {
                            // Store the room name and the list of users in the room in the model and enable
                            // the Current Room drawer option.
                            model.setCurrentRoomName(inRoomDescriptor["roomName"]);
                            model.setCurrentRoomUserList(inRoomDescriptor["users"]);
                            model.setCurrentRoomEnabled(true);
                            model.clearCurrentRoomMessages();
                            // Enable the two creator functions if this is the user that created the room.
                            if (inRoomDescriptor["creator"] == model.userName) {
                              model.setCreatorFunctionsEnabled(true);
                            } else {
                              model.setCreatorFunctionsEnabled(false);
                            }
                            // Navigate to the room screen.
                            Navigator.pushNamed(inContext, "/Room");
                          } else if (inStatus == "full") {
                            Scaffold.of(inBuildContext).showSnackBar(
                              SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                                content : Text("Sorry, that room is full")
                              )
                            );
                          }
                        });
                      }
                    } /* End onTap(). */
                  ),
                  Divider()
                ] /* End Column children. */
              ); /* End Column. */
            } /* End itemBuilder(). */
          ) /* End ListView.builder(). */
        ); /* End Scaffold. */
      } /* End ScopedModel.builder(). */
    )); /* End ScopedModel/ScopedModelDescendant. */

  } /* End build(). */


} /* End class. */