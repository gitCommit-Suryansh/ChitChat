import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { ChatState } from "../../Context/ChatProvider";
import UserListItem from "../UserAvatar/UserListItem";

const SideDrawer = () => {
  const [search, setSearch] = useState("");
  const [searchResult, setSearchResult] = useState([]);
  const [loading, setLoading] = useState(false);
  const [loadingChat, setLoadingChat] = useState(false);
  const [sideMenuOpen, setSideMenuOpen] = useState(false);

  const { setSelectedChat, user, chats, setChats } = ChatState();
  const navigate = useNavigate();

  const logoutHandler = () => {
    localStorage.removeItem("userInfo");
    navigate("/");
  };

  const handleSearch = async () => {
    if (!search) {
      alert("Please enter something in search");
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
      setLoading(false);
      setSearchResult(data);
    } catch (error) {
      alert("Error Occured!");
      setLoading(false);
    }
  };

  const accessChat = async (userId) => {
    try {
      setLoadingChat(true);
      const config = {
        headers: {
          "Content-type": "application/json",
          Authorization: `Bearer ${user.token}`,
        },
      };
      const { data } = await axios.post(`/api/chat`, { userId }, config);

      if (!chats.find((c) => c._id === data._id)) setChats([data, ...chats]);
      setSelectedChat(data);
      setLoadingChat(false);
      setSideMenuOpen(false); // Close drawer
    } catch (error) {
      alert("Error fetching the chat");
      setLoadingChat(false);
    }
  };

  return (
    <>
      <div className="flex justify-between items-center bg-white w-full px-5 py-3 border-b border-gray-200 shadow-sm">
        <button
          className="flex items-center px-3 py-2 text-gray-500 hover:text-gray-800 transition-colors duration-200 focus:outline-none"
          onClick={() => setSideMenuOpen(true)}
        >
          <i className="fas fa-search text-lg"></i>
          <span className="ml-3 hidden md:inline font-medium">Search User</span>
        </button>

        <h2 className="text-2xl font-bold text-teal-600 tracking-tight">
          ChitChat
        </h2>

        <div className="flex items-center">
          <div className="relative group">
            <button className="flex items-center focus:outline-none hover:opacity-80 transition-opacity">
              <img
                className="w-9 h-9 rounded-full border border-gray-300 shadow-sm"
                src={user.pic}
                alt={user.name}
              />
              <i className="fas fa-chevron-down ml-2 text-xs text-gray-500"></i>
            </button>
            {/* Dropdown Menu */}
            <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl py-2 z-50 hidden group-hover:block border border-gray-100 transform origin-top-right transition-all">
              <button className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 w-full text-left transition-colors">
                <i className="fas fa-user mr-2 text-gray-400"></i> My Profile
              </button>
              <div className="border-t border-gray-100 my-1"></div>
              <button
                className="block px-4 py-2 text-sm text-red-600 hover:bg-red-50 w-full text-left transition-colors"
                onClick={logoutHandler}
              >
                <i className="fas fa-sign-out-alt mr-2"></i> Logout
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Side Drawer */}
      {sideMenuOpen && (
        <div className="fixed inset-0 z-50 flex">
          <div
            className="absolute inset-0 bg-black opacity-40 transition-opacity"
            onClick={() => setSideMenuOpen(false)}
          ></div>
          <div className="relative w-80 bg-white h-full shadow-2xl flex flex-col transform transition-transform duration-300 ease-in-out">
            <div className="p-5 border-b border-gray-100 flex justify-between items-center">
              <h2 className="text-xl font-bold text-gray-800">Search Users</h2>
              <button
                onClick={() => setSideMenuOpen(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <i className="fas fa-times"></i>
              </button>
            </div>
            <div className="p-4 flex flex-col gap-3">
              <div className="flex gap-2">
                <input
                  className="flex-1 bg-gray-50 border border-gray-200 rounded-lg px-4 py-2 outline-none focus:border-teal-500 focus:ring-1 focus:ring-teal-500 transition-all"
                  placeholder="Search by name or email"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleSearch()}
                />
                <button
                  className="bg-teal-500 text-white px-4 py-2 rounded-lg hover:bg-teal-600 transition-colors shadow-sm"
                  onClick={handleSearch}
                >
                  Go
                </button>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-2">
              {loading ? (
                <div className="flex justify-center mt-10">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-teal-500"></div>
                </div>
              ) : (
                searchResult?.map((user) => (
                  <UserListItem
                    key={user._id}
                    user={user}
                    handleFunction={() => accessChat(user._id)}
                  />
                ))
              )}
              {loadingChat && (
                <div className="flex justify-center mt-4">
                  <span className="text-teal-500 font-medium animate-pulse">
                    Loading chat...
                  </span>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default SideDrawer;
