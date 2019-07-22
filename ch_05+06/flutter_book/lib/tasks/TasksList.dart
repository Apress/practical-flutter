import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "TasksDBWorker.dart";
import "TasksModel.dart" show Task, TasksModel, tasksModel;


/// ********************************************************************************************************************
/// The Tasks List sub-screen.
/// ********************************************************************************************************************
class TasksList extends StatelessWidget {


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## TasksList.build()");

    // Return widget.
    return ScopedModel<TasksModel>(
      model : tasksModel,
      child : ScopedModelDescendant<TasksModel>(
        builder : (BuildContext inContext, Widget inChild, TasksModel inModel) {
          return Scaffold(
            // Add task.
            floatingActionButton : FloatingActionButton(
              child : Icon(Icons.add, color : Colors.white),
              onPressed : () async {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setChosenDate(null);
                tasksModel.setStackIndex(1);
              }
            ),
            body : ListView.builder(
              // Get the first Card out of the shadow.
              padding : EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount : tasksModel.entityList.length,
              itemBuilder : (BuildContext inBuildContext, int inIndex) {
                Task task = tasksModel.entityList[inIndex];
                // Get the date, if any, in a human-readable format.
                String sDueDate;
                if (task.dueDate != null) {
                  List dateParts = task.dueDate.split(",");
                  DateTime dueDate = DateTime(
                    int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
                  );
                  sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                }
                // Create the Slidable.
                return Slidable(
                  delegate : SlidableDrawerDelegate(),
                  actionExtentRatio : .25,
                  child : ListTile(
                    leading : Checkbox(
                      value : task.completed == "true" ? true : false,
                      onChanged : (inValue) async {
                        // Update the completed value for this task and refresh the list.
                        task.completed = inValue.toString();
                        await TasksDBWorker.db.update(task);
                        tasksModel.loadData("tasks", TasksDBWorker.db);
                      }
                    ),
                    title : Text(
                      "${task.description}",
                      // Dim and strikethrough the text when the task is completed.
                      style : task.completed == "true" ?
                        TextStyle(color : Theme.of(inContext).disabledColor, decoration : TextDecoration.lineThrough) :
                        TextStyle(color : Theme.of(inContext).textTheme.title.color)
                    ),
                    subtitle : task.dueDate == null ?
                      null :
                      Text(
                        sDueDate,
                        // Dim and strikethrough the text when the task is completed.
                        style : task.completed == "true" ?
                          TextStyle(color : Theme.of(inContext).disabledColor, decoration : TextDecoration.lineThrough)
                          :
                          TextStyle(color : Theme.of(inContext).textTheme.title.color)
                      ),
                    // Edit existing task.
                    onTap : () async {
                      // Can't edit a completed task.
                      if (task.completed == "true") { return; }
                      // Get the data from the database and send to the edit view.
                      tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id);
                      // Parse out the due date, if any, and set it in the model for display.
                      if (tasksModel.entityBeingEdited.dueDate == null) {
                        tasksModel.setChosenDate(null);
                      } else {
                        tasksModel.setChosenDate(sDueDate);
                      }
                      tasksModel.setStackIndex(1);
                    }
                  ),
                  secondaryActions : [
                    IconSlideAction(
                      caption : "Delete",
                      color : Colors.red,
                      icon : Icons.delete,
                      onTap : () => _deleteTask(inContext, task)
                    )
                  ]
                ); /* End Slidable. */
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
  /// @param  inTask    The task (potentially) being deleted.
  /// @return           Future.
  Future _deleteTask(BuildContext inContext, Task inTask) async {

    print("## TasksList._deleteTask(): inTask = $inTask");

    return showDialog(
      context : inContext,
      barrierDismissible : false,
      builder : (BuildContext inAlertContext) {
        return AlertDialog(
          title : Text("Delete Task"),
          content : Text("Are you sure you want to delete ${inTask.description}?"),
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
                await TasksDBWorker.db.delete(inTask.id);
                Navigator.of(inAlertContext).pop();
                Scaffold.of(inContext).showSnackBar(
                  SnackBar(
                    backgroundColor : Colors.red,
                    duration : Duration(seconds : 2),
                    content : Text("Task deleted")
                  )
                );
                // Reload data from database to update list.
                tasksModel.loadData("tasks", TasksDBWorker.db);
              }
            )
          ]
        );
      }
    );

  } /* End _deleteTask(). */


} /* End class. */
