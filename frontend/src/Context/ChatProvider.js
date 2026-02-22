import React, { createContext, useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { getToken } from "firebase/messaging";
import { messaging } from "../firebase";

const ChatContext = createContext();

const ChatProvider = ({ children }) => {
  const [selectedChat, setSelectedChat] = useState();
  const [user, setUser] = useState();
  const [notification, setNotification] = useState([]);
  const [chats, setChats] = useState([]);

  const navigate = useNavigate();

  useEffect(() => {
    const userInfo = JSON.parse(localStorage.getItem("userInfo"));
    setUser(userInfo);

    if (!userInfo) {
      navigate("/");
    } else {
      // Setup Firebase Cloud Messaging for Push Notifications
      const setupFCM = async () => {
        try {
          const permission = await Notification.requestPermission();
          if (permission === "granted") {
            // Send Firebase config to the service worker (it can't use process.env)
            if (
              "serviceWorker" in navigator &&
              navigator.serviceWorker.controller
            ) {
              navigator.serviceWorker.controller.postMessage({
                type: "FIREBASE_CONFIG",
                config: {
                  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
                  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
                  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
                  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
                  messagingSenderId:
                    process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
                  appId: process.env.REACT_APP_FIREBASE_APP_ID,
                },
              });
            }

            const currentToken = await getToken(messaging, {
              vapidKey: process.env.REACT_APP_VAPID_KEY,
            });
            if (currentToken) {
              await axios.post(
                "/api/user/fcm-token",
                { fcmToken: currentToken },
                {
                  headers: {
                    Authorization: `Bearer ${userInfo.token}`,
                  },
                },
              );
            }
          }
        } catch (error) {
          console.error("[FCM] Error setting up notifications:", error.message);
        }
      };

      setupFCM();
    }
    // eslint-disable-next-line
  }, [navigate]);

  return (
    <ChatContext.Provider
      value={{
        selectedChat,
        setSelectedChat,
        user,
        setUser,
        notification,
        setNotification,
        chats,
        setChats,
      }}
    >
      {children}
    </ChatContext.Provider>
  );
};

export const ChatState = () => {
  return useContext(ChatContext);
};

export default ChatProvider;
