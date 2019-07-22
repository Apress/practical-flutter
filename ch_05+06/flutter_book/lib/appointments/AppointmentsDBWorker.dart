import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "AppointmentsModel.dart";


/// ********************************************************************************************************************
/// Database provider class for appointments.
/// ********************************************************************************************************************
class AppointmentsDBWorker {


  /// Static instance and private constructor, since this is a singleton.
  AppointmentsDBWorker._();
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();


  /// The one and only database instance.
  Database _db;


  /// Get singleton instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {

    if (_db == null) {
      _db = await init();
    }
    print("## appointments AppointmentsDBWorker.get-database(): _db = $_db");
    return _db;

  } /* End database getter. */


  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {

    String path = join(utils.docsDir.path, "appointments.db");
    print("## appointments AppointmentsDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS appointments ("
            "id INTEGER PRIMARY KEY,"
            "title TEXT,"
            "description TEXT,"
            "apptDate TEXT,"
            "apptTime TEXT"
          ")"
        );
      }
    );
    return db;

  } /* End init(). */


  /// Create a Appointment from a Map.
  Appointment appointmentFromMap(Map inMap) {

    print("## appointments AppointmentsDBWorker.appointmentFromMap(): inMap = $inMap");
    Appointment appointment = Appointment();
    appointment.id = inMap["id"];
    appointment.title = inMap["title"];
    appointment.description = inMap["description"];
    appointment.apptDate = inMap["apptDate"];
    appointment.apptTime = inMap["apptTime"];
    print("## appointments AppointmentsDBWorker.appointmentFromMap(): appointment = $appointment");

    return appointment;

  } /* End appointmentFromMap(); */


  /// Create a Map from a Appointment.
  Map<String, dynamic> appointmentToMap(Appointment inAppointment) {

    print("## appointments AppointmentsDBWorker.appointmentToMap(): inAppointment = $inAppointment");
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inAppointment.id;
    map["title"] = inAppointment.title;
    map["description"] = inAppointment.description;
    map["apptDate"] = inAppointment.apptDate;
    map["apptTime"] = inAppointment.apptTime;
    print("## appointments AppointmentsDBWorker.appointmentToMap(): map = $map");

    return map;

  } /* End appointmentToMap(). */


  /// Create a appointment.
  ///
  /// @param inAppointment the Appointment object to create.
  Future create(Appointment inAppointment) async {

    print("## appointments AppointmentsDBWorker.create(): inAppointment = $inAppointment");

    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    int id = val.first["id"];
    if (id == null) { id = 1; }

    // Insert into table.
    return await db.rawInsert(
      "INSERT INTO appointments (id, title, description, apptDate, apptTime) VALUES (?, ?, ?, ?, ?)",
      [
        id,
        inAppointment.title,
        inAppointment.description,
        inAppointment.apptDate,
        inAppointment.apptTime
      ]
    );

  } /* End create(). */


  /// Get a specific appointment.
  ///
  /// @param  inID The ID of the appointment to get.
  /// @return      The corresponding Appointment object.
  Future<Appointment> get(int inID) async {

    print("## appointments AppointmentsDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("appointments", where : "id = ?", whereArgs : [ inID ]);
    print("## appointments AppointmentsDBWorker.get(): rec.first = $rec.first");
    return appointmentFromMap(rec.first);

  } /* End get(). */


  /// Get all appointments.
  ///
  /// @return A List of Appointment objects.
  Future<List> getAll() async {

    Database db = await database;
    var recs = await db.query("appointments");
    var list = recs.isNotEmpty ? recs.map((m) => appointmentFromMap(m)).toList() : [ ];

    print("## appointments AppointmentsDBWorker.getAll(): list = $list");

    return list;

  } /* End getAll(). */


  /// Update a appointment.
  ///
  /// @param inAppointment The appointment to update.
  Future update(Appointment inAppointment) async {

    print("## appointments AppointmentsDBWorker.update(): inAppointment = $inAppointment");

    Database db = await database;
    return await db.update(
      "appointments", appointmentToMap(inAppointment), where : "id = ?", whereArgs : [ inAppointment.id ]
    );

  } /* End update(). */


  /// Delete a appointment.
  ///
  /// @param inID The ID of the appointment to delete.
  Future delete(int inID) async {

    print("## appointments AppointmentsDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("appointments", where : "id = ?", whereArgs : [ inID ]);

  } /* End delete(). */


} /* End class. */