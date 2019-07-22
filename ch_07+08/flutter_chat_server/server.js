// The collection of user descriptors currently known to the server, keyed by name.  Each element is:
//   userName : { userName : "", password : "" }
// noinspection JSUnusedLocalSymbols
const users = { };


// The collection of room descriptors of the current rooms on the server, keyed by name.  Each element is:
//   roomName : { roomName : "", description : "", maxPeople : 99, private : true|false,
//     creator : "",
//     users : [
//       userName : { userName : "" },
//       ...
//     ]
//   }
// noinspection JSUnusedLocalSymbols
const rooms = { };


// construct an HTTP server, wrapped in an Socket.IO server, and start it up.
const io = require("socket.io")(require("http").createServer(function(){}).listen(80));


// noinspection JSUnresolvedFunction
/**
 * Handle the socket connection event.  All other events must be hooked up inside this.
 */
io.on("connection", io => {


  console.log("\n\nConnection established with a client");


  // --------------------------------------------- USER MESSAGES ---------------------------------------------


  /**
   * Client emits this to validate the user.
   *
   * inData
   *   { userName : "", password : "" }
   *
   * Callback
   *   { status : "ok|fail|created" }
   * Broadcast (only if status=created)
   *   newUser <the users collection>
   */
  io.on("validate", (inData, inCallback) => {

    console.log("\n\nMSG: validate");

    console.log(`inData = ${JSON.stringify(inData)}`);

    const user = users[inData.userName];
    console.log(`user = ${JSON.stringify(user)}`);
    if (user) {
      if (user.password === inData.password) {
        console.log("User logged in");
        inCallback({ status : "ok" });
      } else {
        console.log("Password incorrect");
        inCallback({ status : "fail" });
      }
    } else {
      console.log("User created");
      console.log(`users = ${JSON.stringify(users)}`);
      users[inData.userName] = inData;
      console.log(`users = ${JSON.stringify(users)}`);
      // noinspection JSUnresolvedVariable
      io.broadcast.emit("newUser", users);
      inCallback({ status : "created" });
    }

  }); /* End validate handler. */


  /**
   * Client emits this to invite a user to a room.
   *
   * inData
   *   { userName : "", roomName : "", inviterName : "" }
   *
   * Callback
   *   { status : "ok" }
   * Broadcast
   *   invited { userName : "", inviterName : "", roomName : "" }
   */
  io.on("invite", (inData, inCallback) => {

    console.log("\n\nMSG: invite", inData);

    // noinspection JSUnresolvedVariable
    io.broadcast.emit("invited", inData);
    inCallback({ status : "ok" });

  }); /* End invite handler. */


  /**
   * Client emits this to kick a user from a room.
   *
   * inData
   *   { userName : "", roomName : "" }
   *
   * Callback
   *   { status : "ok" }
   * Broadcast
   *   kicked <room descriptor>
   */
  io.on("kick", (inData, inCallback) => {

    console.log("\n\nMSG: kick", inData);

    const room = rooms[inData.roomName];
    console.log(`room = ${JSON.stringify(room)}`);
    const users = room.users;
    console.log(`users = ${JSON.stringify(users)}`);
    delete users[inData.userName];
    console.log(`users = ${JSON.stringify(users)}`);
    console.log(`room = ${JSON.stringify(room)}`);

    // noinspection JSUnresolvedVariable
    io.broadcast.emit("kicked", room);
    inCallback({ status : "ok" });

  }); /* End kickUser handler. */


  /**
   * Client emits this to get a list of all user currently known to the server.
   *
   * inData
   *   { }
   *
   * Callback
   *   <the users collection>
   */
  io.on("listUsers", (inData, inCallback) => {

    console.log("\n\nMSG: listUsers", inData);

    console.log("Returning: " + JSON.stringify(users));
    inCallback(users);

  }); /* End listUsers handler. */


  // --------------------------------------------- ROOM MESSAGES ---------------------------------------------


  /**
   * Client emits this to get a list of rooms.
   *
   * inData
   *   { }
   *
   * Callback
   *   <the rooms collection>
   */
  io.on("listRooms", (inData, inCallback) => {

    console.log("\n\nMSG: listRooms", rooms);

    console.log("Returning: " + JSON.stringify(rooms));
    inCallback(rooms);

  }); /* End listRooms handler. */


  /**
   * Client emits this to create a room.
   *
   * inData
   *   { roomName : "", description : "", maxPeople : 99, private : true|false, creator : "" }
   *
   * If roomName not already in use:
   *   Broadcast
   *     created <the rooms collection>
   *   Callback
   *     { status : "created", rooms : <the rooms collection> }
   *
   * If room name is already in use:
   *   Callback
   *     { status : "exists" }
   *
   */
  io.on("create", (inData, inCallback) => {

    console.log("\n\nMSG: create", inData);

    // noinspection JSUnresolvedVariable
    if (rooms[inData.roomName]) {
      console.log("Room already exists");
      inCallback({ status : "exists" });
    } else {
      console.log("Creating room");
      inData.users = { };
      console.log(`inData: ${JSON.stringify(inData)}`);
      console.log(`rooms = ${JSON.stringify(rooms)}`);
      rooms[inData.roomName] = inData;
      console.log(`rooms = ${JSON.stringify(rooms)}`);
      // noinspection JSUnresolvedVariable
      io.broadcast.emit("created", rooms);
      inCallback({ status : "created", rooms : rooms });
    }

  }); /* End create handler. */


  /**
   * Client emits this to join a room.
   *
   * inData
   *   { userName : "", roomName : "" }
   *
   * If the room is not full:
   *   Broadcast
   *     joined <room descriptor>
   *   Callback
   *     { status : "joined", room : <room descriptor> }
   *
   * If the room is full:
   *   Callback
   *     { status : "full" }
   *
   */
  io.on("join", (inData, inCallback) => {

    console.log("\n\nMSG: join", inData);

    const room = rooms[inData.roomName];
    console.log(`room = ${JSON.stringify(room)}`);
    if (Object.keys(room.users).length >= rooms.maxPeople) {
      console.log("Room is full");
      inCallback({ status : "full" });
    } else {
      console.log(`room.users BEFORE = ${JSON.stringify(room.users)}`);
      room.users[inData.userName] = users[inData.userName];
      console.log(`room.users AFTER = ${JSON.stringify(room.users)}`);
      // noinspection JSUnresolvedVariable
      io.broadcast.emit("joined", room);
      // noinspection JSUnusedGlobalSymbols
      inCallback({status : "joined", room : room });
    }

  }); /* End join handler. */


  /**
   * Client emits this to leave a room.
   *
   * inData
   *   { userName : "", roomName : "" }
   *
   * Broadcast
   *   left <room descriptor>
   * Callback
   *   { status : "ok" }
   */
  io.on("leave", (inData, inCallback) => {

    console.log("\n\nMSG: leave", inData);

    const room = rooms[inData.roomName];
    delete room.users[inData.userName];

    // noinspection JSUnresolvedVariable
    io.broadcast.emit("left", room);
    inCallback({status : "ok" });

  }); /* End leave handler. */


  /**
   * Client emits this to close a room.
   *
   * inData
   *   { roomName : "" }
   *
   * Broadcast
   *   { roomName : "", rooms : <the rooms collection> }
   * Callback
   *   <the rooms collection>
   */
  io.on("close", (inData, inCallback) => {

    console.log("\n\nMSG: close", inData);

    delete rooms[inData.roomName];

    // noinspection JSUnresolvedVariable
    io.broadcast.emit("closed", { roomName : inData.roomName, rooms : rooms });
    inCallback(rooms);

  }); /* End close handler. */


  // -------------------------------------------- MESSAGE MESSAGES -------------------------------------------


  /**
   * Client emits this to post a message to a room.
   *
   * inData
   *   { userName : "", roomName : "", message : "" }
   *
   * Callback
   *   { status : "ok" }
   * Broadcast
   *   posted { userName : "", roomName : "", message : "" }
   */
  io.on("post", (inData, inCallback) => {

    console.log("\n\nMSG: post", inData);

    // noinspection JSUnresolvedVariable
    io.broadcast.emit("posted", inData);
    inCallback({ status : "ok" });

  }); /* End post handler. */


}); /* End connection event handler. */


console.log("Server ready");
