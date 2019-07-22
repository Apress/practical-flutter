import "package:flutter/material.dart";
import "GameObject.dart";


/// A type of GameObject specific to the player.  Needed because the player can of course can move.
class Player extends GameObject {


  /// The speed this object moves per game loop tick in pixels.
  int speed = 0;

  /// Which way the player is moving along the horizontal axis, if at all.  0=not moving, 1=right, -1=left.
  int moveHorizontal = 0;

  /// Which way the player is moving along the vertical axis, if at all.  0=not moving, 1=down, -1=up.
  int moveVertical = 0;

  /// The amount of energy currently onboard the ship.
  double energy = 0.0;

  /// A precalculated table of angles to radians, to avoid calculations and local vars.
  Map anglesToRadiansConversionTable = {
    "angle45" : 0.7853981633974483,
    "angle90" : 1.5707963267948966,
    "angle135" : 2.3387411976724017,
    "angle180" : 3.141592653589793,
    "angle225" : 3.9269908169872414,
    "angle270" : 4.71238898038469,
    "angle315" : 5.497787143782138
  };

  /// The number of radians the player is currently rotated by.
  double radians = 0.0;


  /// Constructor.
  Player(double inScreenWidth, double inScreenHeight, String inBaseFilename,
    int inWidth, int inHeight,
    int inNumFrames, int inFrameSkip, int inSpeed,
  ) : super(inScreenWidth, inScreenHeight, inBaseFilename, inWidth, inHeight, inNumFrames, inFrameSkip, null) {
    speed = inSpeed;
  }


  /// Returns a widget that is the visual representation of this object.  For the player, we need to rotate
  /// as appropriate for movement, hence the override of draw() in GameObject.
  @override
  Widget draw() {

    return visible ?
      Positioned(left : x, top : y, child : Transform.rotate(angle : radians, child : frames[currentFrame])) :
      Positioned(child : Container());

  } /* End draw(). */


  /// Move the player.
  void move() {

    if (x > 0 && moveHorizontal == -1) {
      x = x - speed;
    }
    if (x < (screenWidth - width) && moveHorizontal == 1) {
      x = x + speed;
    }
    if (y > 40 && moveVertical == -1) {
      y = y - speed;
    }
    if (y < (screenHeight - height - 10) && moveVertical == 1) {
      y = y + speed;
    }

  } /* End move(). */


  /// Called whenever the player's orientation changes.
  void orientationChanged() {

    radians = 0.0;
    if (moveHorizontal == 1 && moveVertical == -1) {
      radians = anglesToRadiansConversionTable["angle45"];
    } else if (moveHorizontal == 1 && moveVertical == 0) {
      radians = anglesToRadiansConversionTable["angle90"];
    } else if (moveHorizontal == 1 && moveVertical == 1) {
      radians = anglesToRadiansConversionTable["angle135"];
    } else if (moveHorizontal == 0 && moveVertical == 1) {
      radians = anglesToRadiansConversionTable["angle180"];
    } else if (moveHorizontal == -1 && moveVertical == 1) {
      radians = anglesToRadiansConversionTable["angle225"];
    } else if (moveHorizontal == -1 && moveVertical == 0) {
      radians = anglesToRadiansConversionTable["angle270"];
    } else if (moveHorizontal == -1 && moveVertical == -1) {
      radians = anglesToRadiansConversionTable["angle315"];
    }

  } /* End orientationChanged(). */


} /* End class. */
