import React, { useEffect, useState } from "react";
import { ChatState } from "../Context/ChatProvider";
import axios from "axios";
import ScrollableChat from "./ScrollableChat";
import io from "socket.io-client";
import UpdateGroupChatModal from "./miscellaneous/UpdateGroupChatModal";

// Should be endpoint
const ENDPOINT = process.env.REACT_APP_BACKEND_URL;
var socket, selectedChatCompare;

const SingleChat = ({ fetchAgain, setFetchAgain }) => {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [newMessage, setNewMessage] = useState("");
  const [socketConnected, setSocketConnected] = useState(false);
  const [typing, setTyping] = useState(false);
  const [istyping, setIsTyping] = useState(false);

  const { user, selectedChat, setSelectedChat, notification, setNotification } =
    ChatState();

  const fetchMessages = async () => {
    if (!selectedChat) return;

    try {
      const config = {
        headers: {
          Authorization: `Bearer ${user.token}`,
        },
      };
      setLoading(true);
      const { data } = await axios.get(
        `/api/message/${selectedChat._id}`,
        config,
      );
      setMessages(data);
      setLoading(false);
      socket.emit("join chat", selectedChat._id);
    } catch (error) {
      alert("Error fetching messages");
    }
  };

  const sendMessage = async (event) => {
    if (event.key === "Enter" && newMessage) {
      socket.emit("stop typing", selectedChat._id);
      try {
        const config = {
          headers: {
            "Content-type": "application/json",
            Authorization: `Bearer ${user.token}`,
          },
        };
        setNewMessage("");
        const { data } = await axios.post(
          "/api/message",
          {
            content: newMessage,
            chatId: selectedChat._id,
          },
          config,
        );
        socket.emit("new message", data);
        setMessages([...messages, data]);
      } catch (error) {
        alert("Error sending message");
      }
    }
  };

  useEffect(() => {
    socket = io(ENDPOINT);
    socket.emit("setup", user);
    socket.on("connected", () => setSocketConnected(true));
    socket.on("typing", () => setIsTyping(true));
    socket.on("stop typing", () => setIsTyping(false));
  }, []); // eslint-disable-line

  useEffect(() => {
    fetchMessages();
    selectedChatCompare = selectedChat;
    // eslint-disable-next-line
  }, [selectedChat]);

  useEffect(() => {
    socket.on("message received", (newMessageRecieved) => {
      if (
        !selectedChatCompare || // if chat is not selected or doesn't match current chat
        selectedChatCompare._id !== newMessageRecieved.chat._id
      ) {
        if (!notification.includes(newMessageRecieved)) {
          setNotification([newMessageRecieved, ...notification]);
          setFetchAgain(!fetchAgain);
        }
      } else {
        setMessages([...messages, newMessageRecieved]);
      }
    });
  });

  const typingHandler = (e) => {
    setNewMessage(e.target.value);

    // Typing Indicator Logic
    if (!socketConnected) return;

    if (!typing) {
      setTyping(true);
      socket.emit("typing", selectedChat._id);
    }
    let lastTypingTime = new Date().getTime();
    var timerLength = 3000;
    setTimeout(() => {
      var timeNow = new Date().getTime();
      var timeDiff = timeNow - lastTypingTime;
      if (timeDiff >= timerLength && typing) {
        socket.emit("stop typing", selectedChat._id);
        setTyping(false);
      }
    }, timerLength);
  };

  return (
    <>
      {selectedChat ? (
        <>
          <div className="flex items-center justify-between p-3 bg-white border-b border-gray-200 shadow-sm h-[70px]">
            <div className="flex items-center">
              <button
                className="md:hidden mr-3 text-gray-600 hover:text-gray-800"
                onClick={() => setSelectedChat("")}
              >
                <i className="fas fa-arrow-left"></i>
              </button>

              <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center mr-3 text-lg font-bold text-gray-600 border border-gray-300">
                {!selectedChat.isGroupChat
                  ? selectedChat.users
                      .find((u) => u._id !== user._id)
                      ?.name[0].toUpperCase()
                  : selectedChat.chatName[0].toUpperCase()}
              </div>

              <div className="flex flex-col justify-center">
                <h2 className="text-lg font-semibold text-gray-800 leading-tight">
                  {!selectedChat.isGroupChat ? (
                    <>
                      {selectedChat.users.find((u) => u._id !== user._id)?.name}
                    </>
                  ) : (
                    <div className="flex items-center">
                      <span className="mr-2">
                        {selectedChat.chatName.toUpperCase()}
                      </span>
                    </div>
                  )}
                </h2>
                <p className="text-xs text-gray-500 leading-tight">
                  {!selectedChat.isGroupChat ? "Click for info" : "Group Chat"}
                </p>
              </div>
            </div>

            {selectedChat.isGroupChat && (
              <UpdateGroupChatModal
                fetchAgain={fetchAgain}
                setFetchAgain={setFetchAgain}
                fetchMessages={fetchMessages}
              />
            )}
          </div>

          <div className="flex flex-col justify-end p-3 w-full h-full overflow-hidden relative chat-background">
            {loading ? (
              <div className="flex items-center justify-center h-full">
                <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-teal-500"></div>
              </div>
            ) : (
              <div className="messages flex flex-col overflow-y-scroll scrollbar-hide mb-2">
                <ScrollableChat messages={messages} />
              </div>
            )}

            <div className="mt-auto">
              {istyping ? (
                <div className="inline-block bg-white/80 rounded px-2 py-1 text-xs text-gray-500 mb-2 italic shadow-sm">
                  Someone is typing...
                </div>
              ) : (
                <></>
              )}
              <div className="flex items-center bg-white rounded-full px-4 py-2 border border-gray-300 shadow-md">
                <input
                  className="flex-1 bg-transparent outline-none text-gray-700 text-sm md:text-base"
                  placeholder="Type a message..."
                  onChange={typingHandler}
                  value={newMessage}
                  onKeyDown={sendMessage}
                />
                <button
                  className="ml-2 text-teal-600 hover:text-teal-700 transition-colors duration-200"
                  onClick={() => sendMessage({ key: "Enter" })}
                >
                  <i className="fas fa-paper-plane text-lg"></i>
                </button>
              </div>
            </div>
          </div>
        </>
      ) : (
        <div className="flex flex-col items-center justify-center h-full bg-gray-50">
          <div className="text-6xl text-gray-300 mb-6">
            <i className="far fa-comments"></i>
          </div>
          <h2 className="text-2xl pb-2 font-bold text-gray-500">
            Welcome to Chat App
          </h2>
          <p className="text-gray-400">Select a chat to start messaging</p>
        </div>
      )}
    </>
  );
};

export default SingleChat;
