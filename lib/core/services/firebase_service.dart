import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> init() async {
    try {
      // Initialize Firebase core
      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully.');
    } catch (e) {
      debugPrint('=========================================');
      debugPrint('WARNING: Firebase initialization failed.');
      debugPrint('Please add google-services.json for Android or GoogleService-Info.plist for iOS.');
      debugPrint('Continuing in development fallback mode.');
      debugPrint('Error: $e');
      debugPrint('=========================================');
    }
  }
}
