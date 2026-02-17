import React from "react";
import { ChatState } from "../Context/ChatProvider";
import SingleChat from "./SingleChat";

const ChatBox = ({ fetchAgain, setFetchAgain }) => {
  const { selectedChat } = ChatState();

  return (
    <div
      className={`flex items-center flex-col p-3 bg-white w-full md:w-2/3 rounded-lg border border-gray-200 ml-0 md:ml-2 ${selectedChat ? "flex" : "hidden md:flex"}`}
    >
      <SingleChat fetchAgain={fetchAgain} setFetchAgain={setFetchAgain} />
    </div>
  );
};

export default ChatBox;
