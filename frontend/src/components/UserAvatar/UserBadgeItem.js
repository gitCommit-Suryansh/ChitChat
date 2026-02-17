import React from "react";

const UserBadgeItem = ({ user, handleFunction }) => {
  return (
    <div
      className="px-2 py-1 rounded-lg m-1 mb-2 bg-purple-500 text-white cursor-pointer flex items-center"
      onClick={handleFunction}
    >
      {user.name}
      <i className="pl-1 fas fa-times"></i>
    </div>
  );
};

export default UserBadgeItem;
