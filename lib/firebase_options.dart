// File generated for FlutterFire.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxexhNbvBzwllJiiMqPvdsWXh3zOzJ-yI',
    appId: '1:102938475610:web:a1b2c3d4e5f60718293a4b',
    messagingSenderId: '102938475610',
    projectId: 'eataly-aishlat-2322',
    authDomain: 'eataly-aishlat-2322.firebaseapp.com',
    storageBucket: 'eataly-aishlat-2322.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxexhNbvBzwllJiiMqPvdsWXh3zOzJ-yI',
    appId: '1:102938475610:android:a1b2c3d4e5f60718293a4b',
    messagingSenderId: '102938475610',
    projectId: 'eataly-aishlat-2322',
    storageBucket: 'eataly-aishlat-2322.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBxexhNbvBzwllJiiMqPvdsWXh3zOzJ-yI',
    appId: '1:102938475610:web:a1b2c3d4e5f60718293a4b',
    messagingSenderId: '102938475610',
    projectId: 'eataly-aishlat-2322',
    authDomain: 'eataly-aishlat-2322.firebaseapp.com',
    storageBucket: 'eataly-aishlat-2322.firebasestorage.app',
  );
}

