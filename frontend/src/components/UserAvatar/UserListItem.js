import React from "react";

const UserListItem = ({ user, handleFunction }) => {
  return (
    <div
      onClick={handleFunction}
      className="cursor-pointer bg-gray-100 hover:bg-blue-500 hover:text-white w-full flex items-center p-2 mb-2 rounded transition-colors duration-200"
    >
      <img
        className="w-8 h-8 rounded-full mr-2"
        src={user.pic}
        alt={user.name}
      />
      <div>
        <p className="font-semibold">{user.name}</p>
        <p className="text-xs">
          <b>Email:</b> {user.email}
        </p>
      </div>
    </div>
  );
};

export default UserListItem;
