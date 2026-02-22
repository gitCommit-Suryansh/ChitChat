import { initializeApp } from "firebase/app";
import { getMessaging } from "firebase/messaging";

const firebaseConfig = {
  apiKey: "AIzaSyD9SicHek79bdUpFVPOQgQoTqHjHRgs5XU",
  authDomain: "chitchatfcm-edd08.firebaseapp.com",
  projectId: "chitchatfcm-edd08",
  storageBucket: "chitchatfcm-edd08.firebasestorage.app",
  messagingSenderId: "136852496455",
  appId: "1:136852496455:web:5449e094ce37b55f28d162",
  measurementId: "G-4B2WPXRSQV",
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

export { app, messaging };
