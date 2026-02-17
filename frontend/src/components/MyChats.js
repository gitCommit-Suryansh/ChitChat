import React, { useEffect, useState } from "react";
import { ChatState } from "../Context/ChatProvider";
import axios from "axios";

import GroupChatModal from "./miscellaneous/GroupChatModal";

const MyChats = ({ fetchAgain }) => {
  const [loggedUser, setLoggedUser] = useState();
  const { selectedChat, setSelectedChat, user, chats, setChats } = ChatState();

  const fetchChats = async () => {
    try {
      const config = {
        headers: {
          Authorization: `Bearer ${user.token}`,
        },
      };

      const { data } = await axios.get("/api/chat", config);
      setChats(data);
    } catch (error) {
      alert("Error fetching chats");
    }
  };

  useEffect(() => {
    setLoggedUser(JSON.parse(localStorage.getItem("userInfo")));
    fetchChats();
    // eslint-disable-next-line
  }, [fetchAgain]);

  return (
    <div
      className={`flex-col p-3 bg-white w-full md:w-1/3 border-r border-gray-200 ${selectedChat ? "hidden md:flex" : "flex"}`}
    >
      <div className="flex justify-between items-center pb-3 px-3 font-sans">
        <h2 className="text-2xl font-bold text-gray-800">My Chats</h2>
        <GroupChatModal>
          <button className="flex items-center text-sm bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-2 rounded-lg transition-colors duration-200">
            <span className="mr-2">New Group</span>
            <i className="fas fa-plus"></i>
          </button>
        </GroupChatModal>
      </div>

      <div className="flex flex-col p-3 bg-gray-50 w-full h-full rounded-lg overflow-hidden">
        {chats ? (
          <div className="overflow-y-scroll scrollbar-hide space-y-2">
            {chats.map((chat) => (
              <div
                onClick={() => setSelectedChat(chat)}
                className={`cursor-pointer w-full flex items-center px-3 py-3 rounded-lg transition-all duration-200 ${
                  selectedChat === chat
                    ? "bg-teal-500 text-white shadow-md transform scale-[1.02]"
                    : "bg-white text-gray-800 hover:bg-gray-100 shadow-sm"
                }`}
                key={chat._id}
              >
                <div className="mr-3">
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center text-lg font-bold ${selectedChat === chat ? "bg-white text-teal-500" : "bg-teal-100 text-teal-600"}`}
                  >
                    {!chat.isGroupChat
                      ? chat.users
                          .find((u) => u._id !== loggedUser?._id)
                          ?.name[0].toUpperCase()
                      : chat.chatName[0].toUpperCase()}
                  </div>
                </div>
                <div className="flex flex-col flex-1 overflow-hidden">
                  <div className="font-semibold truncate">
                    {!chat.isGroupChat
                      ? chat.users.find((u) => u._id !== loggedUser?._id)?.name
                      : chat.chatName}
                  </div>
                  {chat.latestMessage && (
                    <p
                      className={`text-xs truncate ${selectedChat === chat ? "text-teal-100" : "text-gray-500"}`}
                    >
                      <b
                        className={`${selectedChat === chat ? "text-white" : "text-gray-700"}`}
                      >
                        {chat.latestMessage.sender.name}:{" "}
                      </b>
                      {chat.latestMessage.content.length > 50
                        ? chat.latestMessage.content.substring(0, 51) + "..."
                        : chat.latestMessage.content}
                    </p>
                  )}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="flex justify-center items-center h-full">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-teal-500"></div>
          </div>
        )}
      </div>
    </div>
  );
};

export default MyChats;
