import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import './providers/auth_provider.dart';
import './providers/chat_provider.dart';
import './screens/login_screen.dart';
import './screens/chat_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'ChitChat',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme,
            ),
            useMaterial3: true,
          ),
          home: auth.user != null
              ? const ChatListScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState == ConnectionState.waiting
                          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                          : const LoginScreen(),
                ),
          routes: {
            ChatListScreen.routeName: (ctx) => const ChatListScreen(),
          },
        ),
      ),
    );
  }
}
