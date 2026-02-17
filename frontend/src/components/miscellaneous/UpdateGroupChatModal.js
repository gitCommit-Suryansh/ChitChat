import React, { useState } from "react";
import axios from "axios";
import { ChatState } from "../../Context/ChatProvider";
import UserBadgeItem from "../UserAvatar/UserBadgeItem";
import UserListItem from "../UserAvatar/UserListItem";

const UpdateGroupChatModal = ({ fetchAgain, setFetchAgain, fetchMessages }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [groupChatName, setGroupChatName] = useState("");
  const [search, setSearch] = useState("");
  const [searchResult, setSearchResult] = useState([]);
  const [loading, setLoading] = useState(false);
  const [renameloading, setRenameloading] = useState(false);

  const { selectedChat, setSelectedChat, user } = ChatState();

  const handleRemove = async (user1) => {
    if (selectedChat.groupAdmin._id !== user._id && user1._id !== user._id) {
      alert("Only admins can remove someone!");
      return;
    }

    try {
      setLoading(true);
      const config = {
        headers: {
          Authorization: `Bearer ${user.token}`,
        },
      };
      const { data } = await axios.put(
        `/api/chat/groupremove`,
        {
          chatId: selectedChat._id,
          userId: user1._id,
        },
        config,
      );

      user1._id === user._id ? setSelectedChat() : setSelectedChat(data);
      setFetchAgain(!fetchAgain);
      fetchMessages();
      setLoading(false);
    } catch (error) {
      alert("Error Occured!");
      setLoading(false);
    }
  };

  const handleAddUser = async (user1) => {
    if (selectedChat.users.find((u) => u._id === user1._id)) {
      alert("User Already in group!");
      return;
    }

    if (selectedChat.groupAdmin._id !== user._id) {
      alert("Only admins can add someone!");
      return;
    }

    try {
      setLoading(true);
      const config = {
        headers: {
          Authorization: `Bearer ${user.token}`,
        },
      };
      const { data } = await axios.put(
        `/api/chat/groupadd`,
        {
          chatId: selectedChat._id,
          userId: user1._id,
        },
        config,
      );

      setSelectedChat(data);
      setFetchAgain(!fetchAgain);
      setLoading(false);
    } catch (error) {
      alert("Error Occured!");
      setLoading(false);
    }
  };

  const handleRename = async () => {
    if (!groupChatName) return;

    try {
      setRenameloading(true);
      const config = {
        headers: {
          Authorization: `Bearer ${user.token}`,
        },
      };
      const { data } = await axios.put(
        `/api/chat/rename`,
        {
          chatId: selectedChat._id,
          chatName: groupChatName,
        },
        config,
      );

      setSelectedChat(data);
      setFetchAgain(!fetchAgain);
      setRenameloading(false);
    } catch (error) {
      alert("Error Occured!");
      setRenameloading(false);
    }
    setGroupChatName("");
  };

  const handleSearch = async (query) => {
    setSearch(query);
    if (!query) {
      return;
    }

    try {
      setLoading(true);
      const config = {
        headers: {
          Authorization: `Bearer ${user.token}`,
        },
      };
      const { data } = await axios.get(`/api/user?search=${search}`, config);
      console.log(data);
      setLoading(false);
      setSearchResult(data);
    } catch (error) {
      alert("Error Occured!");
      setLoading(false);
    }
  };

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="p-2 bg-gray-200 rounded-full hover:bg-gray-300"
      >
        <i className="fas fa-eye"></i>
      </button>

      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
          <div className="bg-white rounded-lg shadow-lg w-full max-w-lg p-6 relative">
            <button
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
              onClick={() => setIsOpen(false)}
            >
              <i className="fas fa-times text-xl"></i>
            </button>
            <h2 className="text-2xl font-bold mb-4 text-center font-sans">
              {selectedChat.chatName}
            </h2>

            <div className="flex flex-col space-y-4">
              <div className="flex flex-wrap w-full pb-3">
                {selectedChat.users.map((u) => (
                  <UserBadgeItem
                    key={u._id}
                    user={u}
                    handleFunction={() => handleRemove(u)}
                  />
                ))}
              </div>
              <div className="flex">
                <input
                  type="text"
                  placeholder="Chat Name"
                  className="input input-bordered w-full p-2 border rounded mr-2"
                  value={groupChatName}
                  onChange={(e) => setGroupChatName(e.target.value)}
                />
                <button
                  className={`btn btn-primary bg-teal-500 text-white p-2 rounded ${renameloading ? "opacity-50 cursor-not-allowed" : ""}`}
                  onClick={handleRename}
                  disabled={renameloading}
                >
                  Update
                </button>
              </div>
              <input
                type="text"
                placeholder="Add User to group"
                className="input input-bordered w-full p-2 border rounded"
                onChange={(e) => handleSearch(e.target.value)}
              />

              {loading ? (
                <div>Loading...</div>
              ) : (
                searchResult?.map((user) => (
                  <UserListItem
                    key={user._id}
                    user={user}
                    handleFunction={() => handleAddUser(user)}
                  />
                ))
              )}
            </div>

            <div className="mt-6 flex justify-end">
              <button
                className="btn btn-danger bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
                onClick={() => handleRemove(user)}
              >
                Leave Group
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default UpdateGroupChatModal;
