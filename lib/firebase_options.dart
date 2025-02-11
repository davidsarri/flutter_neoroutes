// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkcSRnClM-44a6Tzn-ts8pabziGuleZFQ',
    appId: '1:719731019479:web:927333454992c00c406a92',
    messagingSenderId: '719731019479',
    projectId: 'neoroutes-6f21f',
    authDomain: 'neoroutes-6f21f.firebaseapp.com',
    storageBucket: 'neoroutes-6f21f.firebasestorage.app',
    measurementId: 'G-Z0CQRZLHPV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFMn8BK6y1RPAVzUdFFSmeOXnEtO9bmYQ',
    appId: '1:719731019479:android:a65804a8a70f76c6406a92',
    messagingSenderId: '719731019479',
    projectId: 'neoroutes-6f21f',
    storageBucket: 'neoroutes-6f21f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3VLvwgRXqiXYVm_1BTFlMgIrTF8g4K8Q',
    appId: '1:719731019479:ios:713b601812db19e2406a92',
    messagingSenderId: '719731019479',
    projectId: 'neoroutes-6f21f',
    storageBucket: 'neoroutes-6f21f.firebasestorage.app',
    iosBundleId: 'com.example.neoroutes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3VLvwgRXqiXYVm_1BTFlMgIrTF8g4K8Q',
    appId: '1:719731019479:ios:713b601812db19e2406a92',
    messagingSenderId: '719731019479',
    projectId: 'neoroutes-6f21f',
    storageBucket: 'neoroutes-6f21f.firebasestorage.app',
    iosBundleId: 'com.example.neoroutes',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDkcSRnClM-44a6Tzn-ts8pabziGuleZFQ',
    appId: '1:719731019479:web:b068506f5ed8a219406a92',
    messagingSenderId: '719731019479',
    projectId: 'neoroutes-6f21f',
    authDomain: 'neoroutes-6f21f.firebaseapp.com',
    storageBucket: 'neoroutes-6f21f.firebasestorage.app',
    measurementId: 'G-3EMCWFH0NK',
  );
}
