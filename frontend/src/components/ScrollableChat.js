import React, { useRef, useEffect } from "react";
import { ChatState } from "../Context/ChatProvider";

const ScrollableChat = ({ messages }) => {
  const { user, selectedChat } = ChatState();
  const bottomRef = useRef(null);

  useEffect(() => {
    // Scroll to bottom every time messages change
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const isSameSender = (messages, m, i, userId) => {
    return (
      i < messages.length - 1 &&
      (messages[i + 1].sender._id !== m.sender._id ||
        messages[i + 1].sender._id === undefined) &&
      messages[i].sender._id !== userId
    );
  };

  const isLastMessage = (messages, i, userId) => {
    return (
      i === messages.length - 1 &&
      messages[messages.length - 1].sender._id !== userId &&
      messages[messages.length - 1].sender._id
    );
  };

  const isSameUser = (messages, m, i) => {
    return i > 0 && messages[i - 1].sender._id === m.sender._id;
  };

  return (
    <div className="flex flex-col">
      {messages &&
        messages.map((m, i) => (
          <div
            className={`flex ${m.sender._id === user._id ? "justify-end" : "justify-start"} mb-1`}
            key={m._id}
          >
            {(isSameSender(messages, m, i, user._id) ||
              isLastMessage(messages, i, user._id)) && (
              <div
                className="w-8 h-8 mr-1 rounded-full bg-gray-300 flex items-center justify-center text-xs overflow-hidden"
                title={m.sender.name}
              >
                <img src={m.sender.pic} alt={m.sender.name} />
              </div>
            )}
            <span
              className={`rounded-2xl px-4 py-2 max-w-[75%] shadow-sm text-sm md:text-base relative ${
                m.sender._id === user._id
                  ? "bg-teal-100 text-gray-800 rounded-br-none"
                  : "bg-white text-gray-800 rounded-bl-none border border-gray-200"
              } ${
                // Add margin left if it's not the same sender to align with avatar
                m.sender._id !== user._id &&
                !(
                  isSameSender(messages, m, i, user._id) ||
                  isLastMessage(messages, i, user._id)
                )
                  ? "ml-9"
                  : ""
              }`}
            >
              {/* Display Name in Group Chat */}
              {m.sender._id !== user._id &&
                selectedChat &&
                selectedChat.isGroupChat &&
                !isSameUser(messages, m, i) && (
                  <span className="text-xs font-bold text-orange-500 block mb-1">
                    {m.sender.name}
                  </span>
                )}
              {m.content}
            </span>
          </div>
        ))}
      <div ref={bottomRef} />
    </div>
  );
};

export default ScrollableChat;
