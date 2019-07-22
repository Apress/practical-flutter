import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show FlutterChatModel, model;
import "Connector.dart" as connector;


class AppDrawer extends StatelessWidget {


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(final BuildContext inContext) {

    print("## AppDrawer.build()");

    return ScopedModel<FlutterChatModel>(model : model, child : ScopedModelDescendant<FlutterChatModel>(
      builder : (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return Drawer(
          child : Column(children : [
            // Header.
            Container(
              decoration : BoxDecoration(image : DecorationImage(
                image : AssetImage("assets/drawback01.jpg"), fit : BoxFit.cover
              )),
              child : Padding(padding : EdgeInsets.fromLTRB(0, 30, 0, 15),
                child : ListTile(
                  title : Padding(padding : EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child : Center(child : Text(model.userName,
                      style : TextStyle(color : Colors.white, fontSize : 24)
                    ))
                  ),
                  subtitle : Center(child : Text(model.currentRoomName,
                    style : TextStyle(color : Colors.white, fontSize : 16)
                  ))
                )
              )
            ),
            // Lobby (room list).
            Padding(padding : EdgeInsets.fromLTRB(0, 20, 0, 0),
              child : ListTile(
                leading : Icon(Icons.list),
                title : Text("Lobby"),
                onTap: () {
                  // Navigate to new screen, ensuring all others except Home are removed from navigation.
                  Navigator.of(inContext).pushNamedAndRemoveUntil("/Lobby", ModalRoute.withName("/"));
                // Call server to get room list.
                connector.listRooms((inRoomList) {
                  print("## AppDrawer.listRooms: callback: inRoomList=$inRoomList");
                  // Update the model with the new list of rooms.
                  model.setRoomList(inRoomList);
                });
                }
              )
            ),
            // Current Room.
            ListTile(
              enabled : model.currentRoomEnabled,
              leading : Icon(Icons.forum),
              title : Text("Current Room"),
              onTap: () {
                // Navigate to new screen, ensuring all others except Home are removed from navigation.
                Navigator.of(inContext).pushNamedAndRemoveUntil("/Room", ModalRoute.withName("/"));
              }
            ),
            // User List.
            ListTile(
              leading : Icon(Icons.face),
              title : Text("User List"),
              onTap: () {
                // Navigate to new screen, ensuring all others except Home are removed from navigation.
                Navigator.of(inContext).pushNamedAndRemoveUntil("/UserList", ModalRoute.withName("/"));
                // Call server to get user list.
                connector.listUsers((inUserList) {
                  print("## AppDrawer.listUsers: callback: inUserList=$inUserList");
                  // Update the model with the new list of users.
                  model.setUserList(inUserList);
                });
              }
            )
          ]) /* End Column/Column.children. */
        ); /* End Drawer. */
      } /* End ScopedModel.builder(). */
    )); /* End ScopedModel/ScopedModelDescendant. */

  } /* End build(). */


} /* End class. */