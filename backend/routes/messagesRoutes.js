const express = require("express");
const router = express.Router();
const Message = require("../models/messageModel");
const Conversation = require("../models/conversationModel");
const verifyToken = require("../middleware/verifyToken");

router.post("/", verifyToken, async (req, res) => {
  try {
    const senderId = req.user.id;
    const { receiverId, content } = req.body;

    if (!receiverId || !content) {
      return res.status(400).json({ message: "Missing fields" });
    }

    let conversation = await Conversation.findOne({
      participants: { $all: [senderId, receiverId] },
      $expr: { $eq: [{ $size: "$participants" }, 2] },
    });

    if (!conversation) {
      conversation = new Conversation({
        participants: [senderId, receiverId],
      });
      await conversation.save();
    }


    const message = new Message({
      conversation_id: conversation._id,
      sender_id: senderId,
      content,
    });

    await message.save();

    conversation.updatedAt = new Date();
    await conversation.save();

    return res.status(201).json(message);
  } catch (err) {
    console.error("SEND MESSAGE ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

router.get("/:conversationId", verifyToken, async (req, res) => {
  try {
    const { conversationId } = req.params;

    const messages = await Message.find({
      conversation_id: conversationId,
    }).sort({ createdAt: 1 });

    return res.status(200).json(messages);
  } catch (err) {
    console.error("GET MESSAGE ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;