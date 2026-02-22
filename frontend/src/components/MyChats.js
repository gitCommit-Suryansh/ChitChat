import React, { useEffect, useState } from "react";
import { ChatState } from "../Context/ChatProvider";
import axios from "axios";

import GroupChatModal from "./miscellaneous/GroupChatModal";
import io from "socket.io-client";

// Should be endpoint
const ENDPOINT = process.env.REACT_APP_BACKEND_URL;
var socket;

const MyChats = ({ fetchAgain }) => {
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

  const formatTime = (dateString) => {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  };

  useEffect(() => {
    fetchChats();
    // eslint-disable-next-line
  }, [fetchAgain]);

  // Setup Socket for MyChats specifically to keep the list completely real-time without re-fetching
  useEffect(() => {
    socket = io(ENDPOINT);
    if (user) {
      socket.emit("setup", user);
    }
  }, [user]);

  useEffect(() => {
    socket.on("message received", (newMessageReceived) => {
      // Find the chat that matches this message
      const chatIndex = chats?.findIndex(
        (c) => c._id === newMessageReceived.chat._id,
      );

      if (chatIndex > -1) {
        // Chat exists, update it and move to top
        const chatToUpdate = chats[chatIndex];
        const updatedChat = {
          ...chatToUpdate,
          latestMessage: newMessageReceived,
        };
        setChats([
          updatedChat,
          ...chats.filter((c) => c._id !== updatedChat._id),
        ]);
      } else {
        // It's a brand new chat we don't know about, we must fetch
        fetchChats();
      }
    });

    socket.on("messages read updated", (updatedMessages) => {
      setChats((prevChats) => {
        let hasChanges = false;
        const newChats = prevChats.map((chat) => {
          if (chat.latestMessage) {
            const match = updatedMessages.find(
              (um) => um._id === chat.latestMessage._id,
            );
            if (match) {
              hasChanges = true;
              return { ...chat, latestMessage: match };
            }
          }
          return chat;
        });
        return hasChanges ? newChats : prevChats;
      });
    });

    return () => {
      socket.off("message received");
      socket.off("messages read updated");
    };
  }, [chats]);

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
            {chats.map((chat) => {
              const isUnread =
                chat.latestMessage &&
                chat.latestMessage.sender._id !== user?._id &&
                (!chat.latestMessage.readBy ||
                  !chat.latestMessage.readBy.includes(user?._id));

              return (
                <div
                  onClick={() => setSelectedChat(chat)}
                  className={`cursor-pointer w-full flex items-center px-4 py-3 mb-2 rounded-xl transition-all duration-200 border ${
                    selectedChat === chat
                      ? "bg-teal-500 text-white shadow-md border-teal-500"
                      : "bg-white text-gray-800 hover:bg-gray-50 shadow-sm border-gray-100 hover:border-teal-200"
                  }`}
                  key={chat._id}
                >
                  <div className="mr-4 relative">
                    <div
                      className={`w-12 h-12 rounded-full flex items-center justify-center text-xl font-bold shadow-sm ${
                        selectedChat === chat
                          ? "bg-white text-teal-500"
                          : "bg-teal-100 text-teal-600"
                      }`}
                    >
                      {!chat.isGroupChat
                        ? chat.users
                            .find((u) => u._id !== user?._id)
                            ?.name[0].toUpperCase()
                        : chat.chatName[0].toUpperCase()}
                    </div>
                  </div>

                  <div className="flex flex-col flex-1 overflow-hidden justify-center">
                    <div className="flex justify-between items-baseline mb-1">
                      <div
                        className={`text-[15px] truncate pr-2 ${
                          isUnread && selectedChat !== chat
                            ? "font-extrabold text-gray-900"
                            : "font-semibold"
                        }`}
                      >
                        {!chat.isGroupChat
                          ? chat.users.find((u) => u._id !== user?._id)?.name
                          : chat.chatName}
                      </div>
                      {chat.latestMessage && (
                        <div className="flex items-center">
                          <span
                            className={`text-[11px] whitespace-nowrap ml-2 tracking-wide ${
                              selectedChat === chat
                                ? "text-teal-100 font-medium"
                                : isUnread
                                  ? "text-green-600 font-bold"
                                  : "text-gray-400 font-medium"
                            }`}
                          >
                            {formatTime(chat.latestMessage.createdAt)}
                          </span>
                          {isUnread && selectedChat !== chat && (
                            <div className="w-2.5 h-2.5 bg-green-500 rounded-full ml-2"></div>
                          )}
                        </div>
                      )}
                    </div>

                    <div className="flex justify-between items-center">
                      {chat.latestMessage ? (
                        <p
                          className={`text-[13px] truncate w-full flex items-center ${
                            selectedChat === chat
                              ? "text-teal-100"
                              : isUnread
                                ? "text-gray-900 font-bold"
                                : "text-gray-500"
                          }`}
                        >
                          {chat.latestMessage.sender._id === user?._id && (
                            <span
                              className={`mr-1 inline-flex items-center ${
                                selectedChat === chat
                                  ? "text-teal-200"
                                  : chat.latestMessage.readBy &&
                                      chat.latestMessage.readBy.length > 0
                                    ? "text-blue-500"
                                    : "text-gray-400"
                              }`}
                            >
                              <i
                                className={
                                  chat.latestMessage.readBy &&
                                  chat.latestMessage.readBy.length > 0
                                    ? "fas fa-check-double text-[10px]"
                                    : "fas fa-check-double text-[10px]" // Use double check always, coloring handled above
                                }
                              ></i>
                            </span>
                          )}
                          <span className="truncate">
                            {chat.latestMessage.sender._id !== user?._id &&
                              chat.isGroupChat && (
                                <b
                                  className={`${
                                    selectedChat === chat
                                      ? "text-white"
                                      : "text-gray-700"
                                  } mr-1`}
                                >
                                  {chat.latestMessage.sender.name}:
                                </b>
                              )}
                            {chat.latestMessage.content}
                          </span>
                        </p>
                      ) : (
                        <p
                          className={`text-[13px] italic ${
                            selectedChat === chat
                              ? "text-teal-200"
                              : "text-gray-400"
                          }`}
                        >
                          No messages yet
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
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
