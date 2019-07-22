import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "InputController.dart" as InputController;
import "GameCore.dart";


void main() => runApp(FlutterHero());


/// Base widget.
class FlutterHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(title : "FlutterHero", home : GameScreen());
  }
}


/// Main widget.
class GameScreen extends StatefulWidget {
  @override
  GameScreenState createState() => new GameScreenState();
}


/// Main widget state.
class GameScreenState extends State with TickerProviderStateMixin {


  /// Build main widget.
  @override
  Widget build(BuildContext inContext) {

    // Do one-time tasks that require the BuildContext (whether directly or not).
    if (gameLoopController == null) {
      firstTimeInitialization(inContext, this);
    }

    // The List of children for the Stack.
    List<Widget> stackChildren = [
      // Background.
      Positioned(left : 0, top : 0,
        child : Container(width : screenWidth, height : screenHeight,
          decoration : BoxDecoration(image : DecorationImage(
            image : AssetImage("assets/background.png"), fit : BoxFit.cover
          ))
        )
      ),
      // Score.
      Positioned(left : 4, top : 2,
        child : Text('Score: ${score.toString().padLeft(4, "0")}',
          style : TextStyle(color : Colors.white, fontSize : 18, fontWeight : FontWeight.w900)
        )
      ),
      // Energy bar.
      Positioned(left : 120, top : 2, width : screenWidth - 124, height : 22,
        child : LinearProgressIndicator(value : player.energy, backgroundColor : Colors.white,
        valueColor : AlwaysStoppedAnimation(Colors.red)
        )
      ),
      // Crystal.
      crystal.draw()
    ];

    // Add enemies.
    for (int i = 0; i < 3; i++) {
      stackChildren.add(fish[i].draw());
      stackChildren.add(robots[i].draw());
      stackChildren.add(aliens[i].draw());
      stackChildren.add(asteroids[i].draw());
    }

    // Now the planet and the player (must be done after enemies to ensure proper z indexing).
    stackChildren.add(planet.draw());
    stackChildren.add(player.draw());

    // Add any explosions that are currently exploding.
    for (int i = 0; i < explosions.length; i++) {
      stackChildren.add(explosions[i].draw());
    }

    // Return the root widget.
    return Scaffold(body : GestureDetector(
      onPanStart : InputController.onPanStart,
      onPanUpdate : InputController.onPanUpdate,
      onPanEnd : InputController.onPanEnd,
      child : Stack(children : stackChildren)
    )); /* End Scaffold. */

  } /* End build. */


} /* End class. */
