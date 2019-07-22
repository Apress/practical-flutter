import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "AppointmentsDBWorker.dart";
import "AppointmentsList.dart";
import "AppointmentsEntry.dart";
import "AppointmentsModel.dart" show AppointmentsModel, appointmentsModel;


/// ********************************************************************************************************************
/// The Appointments screen.
/// ********************************************************************************************************************
class Appointments extends StatelessWidget {


  /// Constructor.
  Appointments() {

    print("## Appointments.constructor");

    // Initial load of data.
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## Appointments.build()");

    return ScopedModel<AppointmentsModel>(
      model : appointmentsModel,
      child : ScopedModelDescendant<AppointmentsModel>(
        builder : (BuildContext inContext, Widget inChild, AppointmentsModel inModel) {
          return IndexedStack(
            index : inModel.stackIndex,
            children : [
              AppointmentsList(),
              AppointmentsEntry()
            ] /* End IndexedStack children. */
          ); /* End IndexedStack. */
        } /* End ScopedModelDescendant builder(). */
      ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */
