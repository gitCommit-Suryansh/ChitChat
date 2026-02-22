const Message = require("../models/Message");
const User = require("../models/User");
const Chat = require("../models/Chat");

// @description     Get all Messages
// @route           GET /api/message/:chatId
// @access          Protected
const allMessages = async (req, res) => {
  try {
    const messages = await Message.find({ chat: req.params.chatId })
      .populate("sender", "name pic email")
      .populate("chat");
    res.json(messages);
  } catch (error) {
    res.status(400);
    throw new Error(error.message);
  }
};

// @description     Create New Message
// @route           POST /api/message/
// @access          Protected
const sendMessage = async (req, res) => {
  const { content, chatId } = req.body;

  if (!content || !chatId) {
    console.log("Invalid data passed into request");
    return res.sendStatus(400);
  }

  var newMessage = {
    sender: req.user._id,
    content: content,
    chat: chatId,
  };

  try {
    var message = await Message.create(newMessage);

    message = await message.populate("sender", "name pic");
    message = await message.populate("chat");
    message = await User.populate(message, {
      path: "chat.users",
      select: "name pic email",
    });

    await Chat.findByIdAndUpdate(req.body.chatId, { latestMessage: message });

    res.json(message);
  } catch (error) {
    res.status(400);
    throw new Error(error.message);
  }
};

// @description     Mark messages as read
// @route           PUT /api/message/read
// @access          Protected
const markMessagesAsRead = async (req, res) => {
  const { messageIds } = req.body;

  if (!messageIds || messageIds.length === 0) {
    return res.status(400).send({ message: "No message IDs provided" });
  }

  try {
    // Scalable approach: updateMany instead of looping
    await Message.updateMany(
      { _id: { $in: messageIds }, readBy: { $ne: req.user._id } },
      { $addToSet: { readBy: req.user._id } },
    );

    // Fetch the updated messages to return to client or socket
    let updatedMessages = await Message.find({ _id: { $in: messageIds } })
      .populate("sender", "name pic")
      .populate("chat");

    updatedMessages = await require("../models/User").populate(
      updatedMessages,
      {
        path: "chat.users",
        select: "name pic email",
      },
    );

    res.json(updatedMessages);
  } catch (error) {
    res.status(400);
    throw new Error(error.message);
  }
};

module.exports = { allMessages, sendMessage, markMessagesAsRead };
