importScripts(
  "https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js",
);

const firebaseConfig = {
  apiKey: "AIzaSyD9SicHek79bdUpFVPOQgQoTqHjHRgs5XU",
  authDomain: "chitchatfcm-edd08.firebaseapp.com",
  projectId: "chitchatfcm-edd08",
  storageBucket: "chitchatfcm-edd08.firebasestorage.app",
  messagingSenderId: "136852496455",
  appId: "1:136852496455:web:5449e094ce37b55f28d162",
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log(
    "[firebase-messaging-sw.js] Received background message ",
    payload,
  );
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/favicon.ico",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
