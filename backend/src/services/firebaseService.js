const admin = require("firebase-admin");
const serviceAccount = require("../../firebaseServiceAccountKey.json");

// Initialize the Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Helper function to send a push notification
const sendPushNotification = async (
  fcmToken,
  title,
  body,
  dataPayload = {},
) => {
  if (!fcmToken) {
    console.log("Cannot send push notification: No FCM token provided.");
    return false;
  }

  const message = {
    notification: {
      title,
      body,
    },
    data: dataPayload,
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent push notification:", response);
    return true;
  } catch (error) {
    console.error("Error sending push notification:", error);
    return false;
  }
};

module.exports = {
  sendPushNotification,
};
