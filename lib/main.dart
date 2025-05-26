import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pro_voice_assistant/pages/home_page.dart';
import 'package:pro_voice_assistant/pages/signin_page.dart';
import 'package:pro_voice_assistant/theme/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase, catch the exception if it's already initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, so we can use the existing instance
  }

  // Additional web settings
  if (kIsWeb) {
    // Set timestamp settings for web compatibility
    // This can help with timestamp serialization issues
    FirebaseFirestore.instance.settings =
        const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pro voice assistant',
      theme: AppTheme.darkTheme(),
      home: const SignInPage(),
    );
  }
}
