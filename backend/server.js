const http = require("http");
const app = require("./src/app");
const connectDB = require("./src/config/db");
const { Server } = require("socket.io");
const dotenv = require("dotenv");

dotenv.config();

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: [
      "http://localhost:3000",
      "http://localhost:7001",
      "http://147.79.71.199:7001",
      "https://chitchat.bufferworks.in",
    ],
    methods: ["GET", "POST"],
  },
});

// Database Connection
connectDB();

// Socket.io Connection
io.on("connection", (socket) => {
  console.log("Connected to socket.io");
  socket.on("setup", (userData) => {
    socket.join(userData._id);
    socket.emit("connected");
  });

  socket.on("join chat", (room) => {
    socket.join(room);
    console.log("User Joined Room: " + room);
  });
  socket.on("typing", (room) => socket.in(room).emit("typing"));
  socket.on("stop typing", (room) => socket.in(room).emit("stop typing"));

  socket.on("new message", (newMessageRecieved) => {
    var chat = newMessageRecieved.chat;

    if (!chat.users) return console.log("chat.users not defined");

    chat.users.forEach((user) => {
      // if (user._id == newMessageRecieved.sender._id) return;

      socket.in(user._id).emit("message received", newMessageRecieved);
    });
  });

  socket.off("setup", () => {
    console.log("USER DISCONNECTED");
    socket.leave(userData._id);
  });
});

const PORT = process.env.PORT || 7000;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
