const express = require("express");
const router = express.Router();
const Conversation = require("../models/Conversation");
const User = require("../models/User");
const verifyToken = require("../middleware/verifyToken");


router.get("/", verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;

    const conversations = await Conversation.find({
      participants: userId,
    }).sort({ updatedAt: -1 });

    const result = await Promise.all(
      conversations.map(async (conv) => {
        const otherUserId = conv.participants.find(
          (id) => id.toString() !== userId
        );

        const otherUser = await User.findById(otherUserId).select(
          "username email avatar"
        );
        console.log("otherUser:", otherUser);

        // const lastMessage = await Message.findOne({
        //   conversationId: conv._id,
        // }).sort({ createdAt: -1 });
        console.log("participants:", conv.participants);
        console.log("userId:", userId);
        console.log("otherUserId:", otherUserId);
        return {
          conversationId:
            conv._id,

          user:
            otherUser,

          lastMessage:
            conv.lastMessage || "",

          lastMessageTime:
            conv.lastMessageTime ||
            null,
        };
      })
    );

    return res.status(200).json(result);
  } catch (err) {
    console.error("GET CONVERSATION ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

router.post("/", verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { receiverId } = req.body;

    if (!receiverId) {
      return res.status(400).json({ message: "receiverId required" });
    }

    const existing = await Conversation.findOne({
      participants: { $all: [userId, receiverId] },
      $expr: { $eq: [{ $size: "$participants" }, 2] },
    });

    if (existing) {
      return res.status(200).json(existing);
    }

    const conversation = new Conversation({
      participants: [userId, receiverId],
    });

    await conversation.save();

    return res.status(201).json(conversation);
  } catch (err) {
    console.error("CREATE CONVERSATION ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;