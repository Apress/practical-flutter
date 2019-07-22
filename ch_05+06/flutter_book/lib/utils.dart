/// ********************************************************************************************************************
/// A few global utility-type things needed by multiple places in the codebase.
/// ********************************************************************************************************************


import "dart:io";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "BaseModel.dart";


/// The application's document directory for contact avatar image files and database files.
Directory docsDir;


/// Function for getting a selected date from the user.
///
/// @param  inContext The BuildContext of the parent Widget.
/// @return           Future.
Future selectDate(BuildContext inContext, BaseModel inModel, String inDateString) async {

  print("## globals.selectDate()");

  // Default to today's date, assuming we're adding.
  DateTime initialDate = DateTime.now();

  // If editing, set the initialDate to the current birthday, if any.
  if (inDateString != null) {
    List dateParts = inDateString.split(",");
    // Create a DateTime using the year, month and day from dateParts.
    initialDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
  }

  // Now request the date.
  DateTime picked = await showDatePicker(
    context : inContext,
    initialDate : initialDate,
    firstDate : DateTime(1900),
    lastDate : DateTime(2100)
  );

  // If they didn't cancel, update it in the model so it shows on the screen and return the string form.
  if (picked != null) {
    inModel.setChosenDate(DateFormat.yMMMMd("en_US").format(picked.toLocal()));
    return "${picked.year},${picked.month},${picked.day}";
  }

} /* End _selectDate(). */