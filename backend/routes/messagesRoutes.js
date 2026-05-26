const express = require("express");
const router = express.Router();

const Message = require("../models/Message");
const Conversation = require("../models/Conversation");

const verifyToken = require("../middleware/verifyToken");

router.post("/", verifyToken, async (req, res) => {
  try {
    const senderId = req.user.id;

    const { receiverId, content } = req.body;

    // Validate input
    if (
      !receiverId ||
      !content ||
      !content.trim()
    ) {
      return res.status(400).json({
        message: "Missing fields",
      });
    }

    // Find existing 1-1 conversation
    let conversation =
      await Conversation.findOne({
        participants: {
          $all: [senderId, receiverId],
        },

        $expr: {
          $eq: [
            { $size: "$participants" },
            2,
          ],
        },
      });

    // Create new conversation if not exists
    if (!conversation) {
      conversation = new Conversation({
        participants: [
          senderId,
          receiverId,
        ],
      });

      await conversation.save();
    }

    // Create message
    const message = new Message({
      conversationId: conversation._id,

      senderId: senderId,

      content: content.trim(),
    });

    await message.save();

    // Update conversation preview
    conversation.lastMessage =
      message.content;

    conversation.lastMessageTime =
      message.createdAt;

    await conversation.save();

    return res.status(201).json(message);

  } catch (err) {
    console.error(
      "SEND MESSAGE ERROR:",
      err
    );

    return res.status(500).json({
      message: "Server error",
    });
  }
});


// GET MESSAGES
router.get(
  "/:conversationId",
  verifyToken,
  async (req, res) => {

    try {
      const { conversationId } =
        req.params;

      // Check conversation exists
      const conversation =
        await Conversation.findById(
          conversationId
        );

      if (!conversation) {
        return res.status(404).json({
          message:
            "Conversation not found",
        });
      }

      // Authorization check
      const isParticipant =
        conversation.participants.some(
          (id) =>
            id.toString() ===
            req.user.id
        );

      if (!isParticipant) {
        return res.status(403).json({
          message: "Unauthorized",
        });
      }

      const messages =
        await Message.find({
          conversationId:
            conversationId,
        })
          .sort({ createdAt: 1 });

      return res.status(200).json(
        messages
      );

    } catch (err) {

      console.error(
        "GET MESSAGE ERROR:",
        err
      );

      return res.status(500).json({
        message: "Server error",
      });
    }
  }
);

module.exports = router;