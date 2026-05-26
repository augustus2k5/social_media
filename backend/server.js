const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http")
const { Server } = require("socket.io");

const authRoutes = require("./routes/authRoutes");
const conversationsRoutes = require("./routes/conversationsRoutes");
const messagesRoutes = require("./routes/messagesRoutes");
const contactRoutes =
  require("./routes/contactRoutes");

const app = express();
const server = http.createServer(app);
app.use(cors());
app.use(express.json());

const io = new Server(server, {
  cors: {
    origin: "*"
  }
})

mongoose.connect("mongodb://127.0.0.1:27017/socialMediaDB");

app.use("/api/auth", authRoutes);
app.use("/api/conversations", conversationsRoutes);
app.use("/api/messages", messagesRoutes);
app.use(
  "/api/contacts",
  contactRoutes,
);

io.on("connection", (socket) => {
  console.log("A user connected:", socket.id)

  socket.on("joinConversation", (conversationId) => {
    socket.join(conversationId)

    console.log("User joined conversation: ", conversationId)
  })

  socket.on("sendMessage", async (message) => {
    const {
      conversationId,
      senderId,
      content,
    } = messageData;

    try {
      try {

        if (
          !conversationId ||
          !senderId ||
          !content ||
          !content.trim()
        ) {
          return;
        }

        const newMessage = new Message({
          conversationId,
          senderId,
          content: content.trim(),
        });

        await newMessage.save();

        await Conversation.findByIdAndUpdate(
          conversationId,
          {
            lastMessage: content,
            lastMessageTime: new Date(),
          }
        );

        io.to(conversationId).emit(
          "receiveMessage",
          newMessage
        );

      } catch (error) {

        console.log(
          "SOCKET SEND MESSAGE ERROR:",
          error
        );
      }
    } catch (error) {
      console.log(error)
    }
  })

  socket.on("disconnect", () => {
    console.log("User disconnected: ", socket.id)
  })
})

server.listen(5000, "0.0.0.0", () => {
  console.log("Server running on port 5000");
});