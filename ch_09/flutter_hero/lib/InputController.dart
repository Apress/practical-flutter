import "package:flutter/material.dart";
import "Player.dart";


/// The touch "anchor point", that is, the coordinates of the initial touch.
double touchAnchorX;
double touchAnchorY;

/// How many pixels from the anchor point the player has to move their finger to trigger movement.
int moveSensitivity = 20;

/// Reference the player object.
Player player;


/// init.
///
/// @param inPlayer Reference to the player object.
void init(Player inPlayer) {

  player = inPlayer;

} /* End init(). */


/// Triggered when the player places their finger on the screen.  Capture the anchor point here.
///
/// @param inDetails The DragStartDetails object describing the gesture.
void onPanStart(DragStartDetails inDetails) {

  touchAnchorX = inDetails.globalPosition.dx;
  touchAnchorY = inDetails.globalPosition.dy;
  player.moveHorizontal = 0;
  player.moveVertical = 0;

} /* End onPanStart(). */


/// Triggered when the player moves their finger around the screen.
///
/// @param inDetails The DragUpdateDetails object describing the gesture.
void onPanUpdate(DragUpdateDetails inDetails) {

  // Left.
  if (inDetails.globalPosition.dx < touchAnchorX - moveSensitivity) {
    player.moveHorizontal = -1;
    player.orientationChanged();
  // Right.
  } else if (inDetails.globalPosition.dx > touchAnchorX + moveSensitivity) {
    player.moveHorizontal = 1;
    player.orientationChanged();
  // Not far enough to trigger horizontal movement.
  } else {
    player.moveHorizontal = 0;
    player.orientationChanged();
  }
  // Up.
  if (inDetails.globalPosition.dy < touchAnchorY - moveSensitivity) {
    player.moveVertical = -1;
    player.orientationChanged();
  // Down.
  } else if (inDetails.globalPosition.dy > touchAnchorY + moveSensitivity) {
    player.moveVertical = 1;
    player.orientationChanged();
  // Not far enough to trigger vertical movement.
  } else {
    player.moveVertical = 0;
    player.orientationChanged();
  }

} /* End onPanUpdate(). */


/// Triggered when the player lifts their finger from the screen.
///
/// @param inDetails The object describing the gesture.  Note this can be multiple types, hence dynamic.
void onPanEnd(dynamic inDetails) {

  player.moveHorizontal = 0;
  player.moveVertical = 0;

} /* End onPanEnd(). */
