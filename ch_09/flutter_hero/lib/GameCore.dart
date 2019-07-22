import "dart:math";
import "package:flutter/material.dart";
import "package:audioplayers/audio_cache.dart";
import "InputController.dart" as InputController;
import "GameObject.dart";
import "Enemy.dart";
import "Player.dart";


/// Reference to the main State object.
State state;

/// For random number generation throughout.
Random random = new Random();

/// Current score.
int score = 0;

/// Screen dimensions (avoid repetitively getting it).
double screenWidth;
double screenHeight;

/// Controller and Animation for the main game loop.
AnimationController gameLoopController;
Animation gameLoopAnimation;

/// Crystal.
GameObject crystal;

/// Enemies.
List fish;
List robots;
List aliens;
List asteroids;

/// Player.
Player player;

// Planet.
GameObject planet;

/// Any explosions that are currently occurring.
List explosions = [ ];

/// A cache of audio assets.  Needed in order to be able to play audio from assets.
AudioCache audioCache;


/// Perform tasks that must only occur during the very first build() iteration.
///
/// @param inContext The BuildContext passed to build().
void firstTimeInitialization(BuildContext inContext, dynamic inState) {

  // Record reference to the state instance.
  state = inState;

  // Initialize audio cache.
  audioCache = new AudioCache();
  audioCache.loadAll([ "delivery.mp3", "explosion.mp3", "fill.mp3", "thrust.mp3" ]);

  // Get dimensions of screen to avoid looking them up continuously.
  screenWidth = MediaQuery.of(inContext).size.width;
  screenHeight = MediaQuery.of(inContext).size.height;

  // Create the crystal, the planet and the player.
  crystal = GameObject(screenWidth, screenHeight, "crystal", 32, 30, 4, 6, null);
  planet = GameObject(screenWidth, screenHeight, "planet", 64, 64, 1, 0, null);
  player = Player(screenWidth, screenHeight, "player", 40, 34, 2, 6, 2);

  // Create enemies.  Must be done here because we need screenWidth and screenHeight.
  fish = [
    Enemy(screenWidth, screenHeight, "fish", 48, 48, 2, 6, 1, 4),
    Enemy(screenWidth, screenHeight, "fish", 48, 48, 2, 6, 1, 4),
    Enemy(screenWidth, screenHeight, "fish", 48, 48, 2, 6, 1, 4)
  ];
  robots = [
    Enemy(screenWidth, screenHeight, "robot", 48, 48, 2, 6, 0, 3),
    Enemy(screenWidth, screenHeight, "robot", 48, 48, 2, 6, 0, 3),
    Enemy(screenWidth, screenHeight, "robot", 48, 48, 2, 6, 0, 3)
  ];
  aliens = [
    Enemy(screenWidth, screenHeight, "alien", 48, 48, 2, 6, 1, 2),
    Enemy(screenWidth, screenHeight, "alien", 48, 48, 2, 6, 1, 2),
    Enemy(screenWidth, screenHeight, "alien", 48, 48, 2, 6, 1, 2)
  ];
  asteroids = [
    Enemy(screenWidth, screenHeight, "asteroid", 48, 48, 2, 6, 0, 1),
    Enemy(screenWidth, screenHeight, "asteroid", 48, 48, 2, 6, 0, 1),
    Enemy(screenWidth, screenHeight, "asteroid", 48, 48, 2, 6, 0, 1)
  ];

  // Create AnimationController and Animation to serve as our game loop ticker.
  gameLoopController = AnimationController(vsync : inState, duration : Duration(milliseconds : 1000));
  gameLoopAnimation = Tween(begin : 0, end : 17).animate(
    CurvedAnimation(parent : gameLoopController, curve : Curves.linear)
  );

  // Make sure the loop continues "forever".
  gameLoopAnimation.addStatusListener((inStatus) {
    if (inStatus == AnimationStatus.completed) {
      gameLoopController.reset();
      gameLoopController.forward();
    }
  });

  // Hook up the game loop.
  gameLoopAnimation.addListener(gameLoop);

  // Reset all game variables.
  resetGame(true);

  // Initialize input handling.
  InputController.init(player);

  // Start the game loop.
  gameLoopController.forward();

} /* End firstTimeInitialization(). */


/// Reset all game variables to their initial states.
///
/// @param inResetEnemies If true, the position of the enemies will be reset, false to not reset them.
void resetGame(bool inResetEnemies) {

  // Energy on the ship.
  player.energy = 0.0;

  // Set initial position of player and movement.
  player.x = (screenWidth / 2) - (player.width / 2);
  player.y = screenHeight - player.height - 24;
  player.moveHorizontal = 0;
  player.moveVertical = 0;
  player.orientationChanged();

  // Randomly position the crystal (note Y has to be done first or collision detection will fail).
  crystal.y = 34.0;
  randomlyPositionObject(crystal);

  // Randomly position the planet (note Y has to be done first or collision detection will fail).
  planet.y = screenHeight - planet.height - 10;
  randomlyPositionObject(planet);

  // Reset position of enemies, if requested.
  if (inResetEnemies) {
    // Give enemies some variety of spacing.  Slightly bigger gaps near the top to be fair since they're faster.
    List xValsFish = [ 70.0, 192.0, 312.0 ];
    List xValsRobots = [ 64.0, 192.0, 320.0 ];
    List xValsAliens = [ 44.0, 192.0, 340.0 ];
    List xValsAsteroids = [ 24.0, 192.0, 360.0 ];
    for (int i = 0; i < 3; i++ ) {
      fish[i].x = xValsFish[i];
      robots[i].x = xValsRobots[i];
      aliens[i].x = xValsAliens[i];
      asteroids[i].x = xValsAsteroids[i];
      // Y locations get a little closer together near the top.
      fish[i].y = 110.0;
      robots[i].y = fish[i].y + 120;
      aliens[i].y = robots[i].y + 130;
      asteroids[i].y = aliens[i].y + 140;
      fish[i].visible = true;
      robots[i].visible = true;
      aliens[i].visible = true;
      asteroids[i].visible = true;
    }
  }

  // Clear out explosions.
  explosions = [ ];

  // Make sure the player and all enemies is visible.
  player.visible = true;


} /* End resetGame(). */


/// Main game loop.  The real logic of the game is mostly here.
void gameLoop() {

  // Animate crystal.
  crystal.animate();

  // Move and animate enemies.
  for (int i = 0; i < 3; i++) {
    fish[i].move();
    fish[i].animate();
    robots[i].move();
    robots[i].animate();
    aliens[i].move();
    aliens[i].animate();
    asteroids[i].move();
    asteroids[i].animate();
  }

  // Move and animate player.
  player.move();
  player.animate();

  // Animate explosions, if any.
  for (int i = 0; i < explosions.length; i++) {
    explosions[i].animate();
  }

  // Now do hit testing.  First, did the player collide with the crystal?
  if (collision(crystal)) {
    transferEnergy(true);
  // Okay, what about the planet?
  } else if (collision(planet)) {
    transferEnergy(false);
  // Collided with  neither.
  } else {
    // If the player has energy but isn't full, dump it all.  This avoids the "cheat" where they can full the ship
    // only partially but then go get full credit for the delivery.
    if (player.energy > 0 && player.energy < 1) {
      player.energy = 0;
    }
  }

  // Did they collide with any enemy?
  for (int i = 0; i < 3; i++) {
    if (collision(fish[i]) || collision(robots[i]) || collision(aliens[i]) || collision(asteroids[i])) {
      audioCache.play("explosion.mp3");
      player.visible = false;
      GameObject explosion = GameObject(screenWidth, screenHeight, "explosion", 50, 50, 5, 4, () {
        resetGame(false);
      });
      explosion.x = player.x;
      explosion.y = player.y;
      explosions.add(explosion);
      score = score - 50;
      if (score < 0) {
        score = 0;
      }
    }
  }

  // Update state so all the work we did actually matters!
  state.setState(() {});

} /* End mainGameLoop(). */


/// Check for collision between the player and a specified game object.
///
/// @param inObject The GameObject to hit test against the player.
bool collision(GameObject inObject) {

  // Abort if the player isn't visible (i.e., when they're 'splodin).
  if (!player.visible || !inObject.visible) {
    return false;
  }

  // Define the bounding boxes.
  num left1 = player.x;
  num right1 = left1 + player.width;
  num top1 = player.y;
  num bottom1 = top1 + player.height;
  num left2 = inObject.x;
  num right2 = left2 + inObject.width;
  num top2 = inObject.y;
  num bottom2 = top2 + inObject.height;

  // Bounding box checks.  It isn't perfect collision detection, but it's good enough for government work.
  if (bottom1 < top2) {
    return false;
  }
  if (top1 > bottom2) {
    return false;
  }
  if (right1 < left2) {
    return false;
  }
  return left1 <= right2;

} /* End collision(). */


/// Randomly position a game object and test if it collides with the player.
///
/// @param  inObject The GameObject to position.
/// @return          True if the player and this object collided (meaning the object
///                  needs to be repositioned), false if not.
void randomlyPositionObject(GameObject inObject) {

  // Choose a new location, avoiding the edges of the screen.
  inObject.x = (random.nextInt(screenWidth.toInt() - inObject.width)).toDouble();

  // See if this object hits the player.  If it did then try again.
  if (collision(inObject)) {
    randomlyPositionObject(inObject);
  }

} /* End randomlyPosition(). */


/// Transfers that sweet, sweet alien energy either from the crystal to the ship or from the ship to the planet.
///
/// @param inTouchingCrystal True if the player is touching the crystal, false if the planet.
void transferEnergy(bool inTouchingCrystal) {

  if (inTouchingCrystal && player.energy < 1) {

    // Transferring energy from crystal to ship.
    if (player.energy == 0) {
      audioCache.play("fill.mp3");
    }
    player.energy = player.energy + .01;
    // Set value on the bar.
    if (player.energy >= 1) {
      player.energy = 1;
      // Filled up, randomly position crystal.
      randomlyPositionObject(crystal);
    }

  } else if (player.energy > 0) {

    if (player.energy >= 1) {
      audioCache.play("delivery.mp3");
    }
    // Transferring energy from ship to planet.
    player.energy = player.energy - .01;
    // Set value on the bar.
    if (player.energy <= 0) {
      player.energy = 0;
      // Energy delivered, blow up the enemies for the "win".
      audioCache.play("explosion.mp3");
      score = score + 100;
      // For each enemy, hide it, and put an explosion in its place.  When the animation completes, reset
      // the game.
      for (int i = 0; i < 3; i++) {
        Function callback;
        if (i == 0) {
          callback = () {
            resetGame(true);
          };
        }
        fish[i].visible = false;
        GameObject explosion = GameObject(screenWidth, screenHeight, "explosion", 50, 50, 5, 4, callback);
        explosion.x = fish[i].x;
        explosion.y = fish[i].y;
        explosions.add(explosion);
        robots[i].visible = false;
        explosion = GameObject(screenWidth, screenHeight, "explosion", 50, 50, 5, 4, null);
        explosion.x = robots[i].x;
        explosion.y = robots[i].y;
        explosions.add(explosion);
        aliens[i].visible = false;
        explosion = GameObject(screenWidth, screenHeight, "explosion", 50, 50, 5, 4, null);
        explosion.x = aliens[i].x;
        explosion.y = aliens[i].y;
        explosions.add(explosion);
        asteroids[i].visible = false;
        explosion = GameObject(screenWidth, screenHeight, "explosion", 50, 50, 5, 4, null);
        explosion.x = asteroids[i].x;
        explosion.y = asteroids[i].y;
        explosions.add(explosion);
      }
    }

  }

} /* End transferEnergy(). */