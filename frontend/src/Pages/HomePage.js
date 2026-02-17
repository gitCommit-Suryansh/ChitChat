import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Login from "../components/Authentication/Login";
import Signup from "../components/Authentication/Signup";

const HomePage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState("login");

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem("userInfo"));

    if (user) navigate("/chats");
  }, [navigate]);

  return (
    <div
      className="min-h-screen flex items-center justify-center bg-gray-100 bg-cover bg-center"
      style={{
        backgroundImage:
          "url('https://wallpapers.com/images/featured/whatsapp-background-72ms661f0p7667k4.jpg')",
      }}
    >
      <div className="bg-white p-8 rounded-lg shadow-lg w-full max-w-md opacity-95">
        <h1 className="text-3xl font-bold text-center mb-6 font-sans text-gray-800">
          Discuss
        </h1>
        <div className="flex mb-4 border-b">
          <button
            className={`w-1/2 py-2 text-center ${activeTab === "login" ? "border-b-2 border-blue-500 text-blue-500 font-bold" : "text-gray-500"}`}
            onClick={() => setActiveTab("login")}
          >
            Login
          </button>
          <button
            className={`w-1/2 py-2 text-center ${activeTab === "signup" ? "border-b-2 border-blue-500 text-blue-500 font-bold" : "text-gray-500"}`}
            onClick={() => setActiveTab("signup")}
          >
            Sign Up
          </button>
        </div>
        <div className="tab-content transition-all duration-300">
          {activeTab === "login" ? <Login /> : <Signup />}
        </div>
      </div>
    </div>
  );
};

export default HomePage;
