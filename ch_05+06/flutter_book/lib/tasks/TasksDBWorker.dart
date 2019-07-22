import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "TasksModel.dart";


/// ********************************************************************************************************************
/// Database provider class for tasks.
/// ********************************************************************************************************************
class TasksDBWorker {


  /// Static instance and private constructor, since this is a singleton.
  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();


  /// The one and only database instance.
  Database _db;


  /// Get singleton instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {

    if (_db == null) {
      _db = await init();
    }

    print("## tasks TasksDBWorker.get-database(): _db = $_db");

    return _db;

  } /* End database getter. */


  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {

    print("## Tasks TasksDBWorker.init()");

    String path = join(utils.docsDir.path, "tasks.db");
    print("## tasks TasksDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS tasks ("
            "id INTEGER PRIMARY KEY,"
            "description TEXT,"
            "dueDate TEXT,"
            "completed TEXT"
          ")"
        );
      }
    );
    return db;

  } /* End init(). */


  /// Create a Task from a Map.
  Task taskFromMap(Map inMap) {

    print("## Tasks TasksDBWorker.taskFromMap(): inMap = $inMap");

    Task task = Task();
    task.id = inMap["id"];
    task.description = inMap["description"];
    task.dueDate = inMap["dueDate"];
    task.completed = inMap["completed"];

    print("## Tasks TasksDBWorker.taskFromMap(): task = $task");

    return task;

  } /* End taskFromMap(); */


  /// Create a Map from a Task.
  Map<String, dynamic> taskToMap(Task inTask) {

    print("## tasks TasksDBWorker.taskToMap(): inTask = $inTask");

    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inTask.id;
    map["description"] = inTask.description;
    map["dueDate"] = inTask.dueDate;
    map["completed"] = inTask.completed;

    print("## tasks TasksDBWorker.taskToMap(): map = $map");

    return map;

  } /* End taskToMap(). */


  /// Create a task.
  ///
  /// @param  inTask The Task object to create.
  /// @return        Future.
  Future create(Task inTask) async {

    print("## Tasks TasksDBWorker.create(): inTask = $inTask");

    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    int id = val.first["id"];
    if (id == null) { id = 1; }

    // Insert into table.
    return await db.rawInsert(
      "INSERT INTO tasks (id, description, dueDate, completed) VALUES (?, ?, ?, ?)",
      [
        id,
        inTask.description,
        inTask.dueDate,
        inTask.completed
      ]
    );

  } /* End create(). */


  /// Get a specific task.
  ///
  /// @param  inID The ID of the task to get.
  /// @return      The corresponding Task object.
  Future<Task> get(int inID) async {

    print("## Tasks TasksDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("tasks", where : "id = ?", whereArgs : [ inID ]);

    print("## Tasks TasksDBWorker.get(): rec.first = $rec.first");

    return taskFromMap(rec.first);

  } /* End get(). */


  /// Get all tasks.
  ///
  /// @return A List of Task objects.
  Future<List> getAll() async {

    print("## Tasks TasksDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("tasks");
    var list = recs.isNotEmpty ? recs.map((m) => taskFromMap(m)).toList() : [ ];

    print("## Tasks TasksDBWorker.getAll(): list = $list");

    return list;

  } /* End getAll(). */


  /// Update a task.
  ///
  /// @param  inTask The task to update.
  /// @return        Future.
  Future update(Task inTask) async {

    print("## Tasks TasksDBWorker.update(): inTask = $inTask");

    Database db = await database;
    return await db.update("tasks", taskToMap(inTask), where : "id = ?", whereArgs : [ inTask.id ]);

  } /* End update(). */


  /// Delete a task.
  ///
  /// @param  inID The ID of the task to delete.
  /// @return      Future.
  Future delete(int inID) async {

    print("## Taasks TasksDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("Tasks", where : "id = ?", whereArgs : [ inID ]);

  } /* End delete(). */


} /* End class. */