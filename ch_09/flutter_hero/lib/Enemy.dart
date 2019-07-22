import "GameObject.dart";


/// A type of GameObject specific to the four types of enemies.  Needed because enemies can move.
class Enemy extends GameObject {


  /// The speed this object moves per game loop tick in pixels.
  int speed = 0;

  /// What direction this enemy is moving in (0=left, 1 =right);
  int moveDirection = 0;


  /// Constructor.
  Enemy(double inScreenWidth, double inScreenHeight, String inBaseFilename,
    int inWidth, int inHeight, int inNumFrames, int inFrameSkip,
    int inMoveDirection, int inSpeed
  ) : super(inScreenWidth, inScreenHeight, inBaseFilename, inWidth, inHeight, inNumFrames, inFrameSkip, null) {
    speed = inSpeed;
    moveDirection = inMoveDirection;
  }


  /// Move this enemy.
  void move() {

    if (moveDirection == 1) {
      x = x + speed;
      if (x > screenWidth + width) {
        x = -width.toDouble();
      }
    } else {
      x = x - speed;
      if (x < -width) {
        x = screenWidth + width.toDouble();
      }
    }

  } /* End move(). */


} /* End class. */
