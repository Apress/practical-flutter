import "package:flutter/material.dart";


/// Base class for all objects in the game.  This contains the code common to enemies, the player, the crystal
/// and the planet.
class GameObject {


  /// The width of the screen.
  double screenWidth = 0.0;

  /// The height of the screen.
  double screenHeight = 0.0;

  /// Base of the asset files (portion before -X.png).
  String baseFilename = "";

  /// The width of the image assets.
  int width = 0;

  /// The height to the image assets.
  int height = 0;

  /// The X location of this object.
  double x = 0.0;

  /// The Y location of this object.
  double y = 0.0;

  /// The number of frames in this object's animation sequence.
  int numFrames = 0;

  /// How many game loop ticks occur between animation frame changes.
  int frameSkip = 0;

  /// The function to call when the animation sequence completes.  Needed to accommodate explosions.
  Function animationCallback;

  /// The current animation frame showing.
  int currentFrame = 0;

  /// Counter that counts up to frameSkip and then increments currentFrame.
  int frameCount = 0;

  /// The List of Image assets (frames of the animation sequence for this object).
  List frames = [ ];

  /// Is this object visible or not?
  bool visible = true;


  /// Constructor.
  ///
  /// @param inScreenWidth       Value for screenWidth.
  /// @param inScreenHeight      Value for screenHeight.
  /// @param inBaseFilename      Value for baseFilename.
  /// @param inWidth             Value for width.
  /// @param inHeight            Value for height.
  /// @param inNumFrames         Value for numFrames.
  /// @param inFrameSkip         Value for frameSkip.
  /// @param inAnimationCallback The function to call when the animation sequence completes.
  GameObject(double inScreenWidth, double inScreenHeight, String inBaseFilename,
    int inWidth, int inHeight,
    int inNumFrames, int inFrameSkip, Function inAnimationCallback
  ) {

    screenWidth = inScreenWidth;
    screenHeight = inScreenHeight;
    baseFilename = inBaseFilename;
    width = inWidth;
    height = inHeight;
    numFrames = inNumFrames;
    frameSkip = inFrameSkip;
    animationCallback = inAnimationCallback;

    // Load all the animation sequence frames.
    for (int i = 0; i < inNumFrames; i++) {
      frames.add(Image.asset("assets/$baseFilename-$i.png"));
    }

  } /* End constructor. */


  /// Give this game object the opportunity to animate.  Called once per game loop tick.
  void animate() {

    frameCount = frameCount + 1;
    if (frameCount > frameSkip) {
      frameCount = 0;
      currentFrame = currentFrame + 1;
      if (currentFrame == numFrames) {
        currentFrame = 0;
        if (animationCallback != null) {
          animationCallback();
        }
      }
    }

  } /* End animate(). */


  /// Returns a widget that is the visual representation of this object.
  Widget draw() {

    return visible ?
      Positioned(left : x, top : y, child : frames[currentFrame]) :
      Positioned(child : Container());

  } /* End draw(). */


} /* End class. */
