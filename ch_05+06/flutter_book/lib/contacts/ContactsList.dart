import "dart:io";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "package:path/path.dart";
import "../utils.dart" as utils;
import "ContactsDBWorker.dart";
import "ContactsModel.dart" show Contact, ContactsModel, contactsModel;


/// ********************************************************************************************************************
/// The Contacts List sub-screen.
/// ********************************************************************************************************************
class ContactsList extends StatelessWidget {


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## ContactsList.build()");

    // Return widget.
    return ScopedModel<ContactsModel>(
      model : contactsModel,
      child : ScopedModelDescendant<ContactsModel>(
        builder : (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          return Scaffold(
            // Add contact.
            floatingActionButton : FloatingActionButton(
              child : Icon(Icons.add, color : Colors.white),
              onPressed : () async {
                // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                File avatarFile = File(join(utils.docsDir.path, "avatar"));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              }
            ),
            body : ListView.builder(
              itemCount : contactsModel.entityList.length,
              itemBuilder : (BuildContext inBuildContext, int inIndex) {
                Contact contact = contactsModel.entityList[inIndex];
                // Get reference to avatar file and see if it exists.
                File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                bool avatarFileExists = avatarFile.existsSync();
                print("## ContactsList.build(): avatarFile: $avatarFile -- avatarFileExists=$avatarFileExists");
                return Column(
                  children : [
                    Slidable(
                      delegate : SlidableDrawerDelegate(),
                      actionExtentRatio : .25,
                      child : ListTile(
                        leading : CircleAvatar(
                          backgroundColor : Colors.indigoAccent,
                          foregroundColor : Colors.white,
                          backgroundImage : avatarFileExists ? FileImage(avatarFile) : null,
                          child : avatarFileExists ? null : Text(contact.name.substring(0, 1).toUpperCase())
                        ),
                        title : Text("${contact.name}"),
                        subtitle : contact.phone == null ? null : Text("${contact.phone}"),
                        // Edit existing contact.
                        onTap : () async {
                          // Delete avatar file if it exists (it shouldn't, but better safe than sorry!)
                          File avatarFile = File(join(utils.docsDir.path, "avatar"));
                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }
                          // Get the data from the database and send to the edit view.
                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id);
                          // Parse out the  birthday, if any, and set it in the model for display.
                          if (contactsModel.entityBeingEdited.birthday == null) {
                            contactsModel.setChosenDate(null);
                          } else {
                            List dateParts = contactsModel.entityBeingEdited.birthday.split(",");
                            DateTime birthday = DateTime(
                              int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
                            );
                            contactsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(birthday.toLocal()));
                          }
                          contactsModel.setStackIndex(1);
                        }
                      ),
                      secondaryActions : [
                        IconSlideAction(
                          caption : "Delete",
                          color : Colors.red,
                          icon : Icons.delete,
                          onTap : () => _deleteContact(inContext, contact)
                        )
                      ]
                    ),
                    Divider()
                  ]
                ); /* End Column. */
              } /* End itemBuilder. */
            ) /* End ListView.builder. */
          ); /* End Scaffold. */
        } /* End ScopedModelDescendant builder. */
      ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The parent build context.
  /// @param  inContact The contact (potentially) being deleted.
  /// @return           Future.
  Future _deleteContact(BuildContext inContext, Contact inContact) async {

    print("## ContactsList._deleteContact(): inContact = $inContact");

    return showDialog(
      context : inContext,
      barrierDismissible : false,
      builder : (BuildContext inAlertContext) {
        return AlertDialog(
          title : Text("Delete Contact"),
          content : Text("Are you sure you want to delete ${inContact.name}?"),
          actions : [
            FlatButton(child : Text("Cancel"),
              onPressed: () {
                // Just hide dialog.
                Navigator.of(inAlertContext).pop();
              }
            ),
            FlatButton(child : Text("Delete"),
              onPressed : () async {
                // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                // Also, don't forget to delete the avatar file or else new contacts created might wind up with an
                // ID of a file that's present from a previously deleted contact!
                File avatarFile = File(join(utils.docsDir.path, inContact.id.toString()));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                await ContactsDBWorker.db.delete(inContact.id);
                Navigator.of(inAlertContext).pop();
                Scaffold.of(inContext).showSnackBar(
                  SnackBar(
                    backgroundColor : Colors.red,
                    duration : Duration(seconds : 2),
                    content : Text("Contact deleted")
                  )
                );
                // Reload data from database to update list.
                contactsModel.loadData("contacts", ContactsDBWorker.db);
              }
            )
          ]
        );
      }
    );

  } /* End _deleteContact(). */


} /* End class. */
