import "../BaseModel.dart";


/// A class representing this PIM entity type.
class Task {


  /// The fields this entity type contains.
  int id;
  String description;
  String dueDate; // YYYY,MM,DD
  String completed = "false";


  /// Just for debugging, so we get something useful in the console.
  String toString() {
    return "{ id=$id, description=$description, dueDate=$dueDate, completed=$completed }";
  }


} /* End class. */


/// ********************************************************************************************************************
/// The model backing this entity type's views.
/// ********************************************************************************************************************
class TasksModel extends BaseModel {
} /* End class. */


// The one and only instance of this model.
TasksModel tasksModel = TasksModel();
