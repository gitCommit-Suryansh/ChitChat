import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';


// Background message handler (Must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize(String userToken) async {
    // 1. Initialize Firebase Core
    await Firebase.initializeApp();

    // 2. Setup background messaging handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Request permissions for iOS and Android 13+
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // 4. Get the device token
      String? fcmToken = await _firebaseMessaging.getToken();
      
      if (fcmToken != null) {
        print('FCM Token: $fcmToken');
        // 5. Send token to our Node.js backend
        await _sendTokenToBackend(fcmToken, userToken);
      }

      // 6. Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken, userToken);
      });

    } else {
      print('User declined or has not accepted permission');
    }
  }

  static Future<void> _sendTokenToBackend(String fcmToken, String userToken) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/user/fcm-token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully registered FCM token with backend.');
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending FCM token to backend: $e');
    }
  }
}
