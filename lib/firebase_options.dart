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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static   FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDL38SmVHcXPQ6TJo00VTlMiau8qS36iyk',
    appId: '1:253230272977:android:8d748a98babdb87b8850f0',
    messagingSenderId: '253230272977',
    projectId: 'chatapp-d3701',
    storageBucket: 'chatapp-d3701.appspot.com',
  );

  static   FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDhKmWmw1mm1vfJtPbXaM34BEv2R0rVKA',
    appId: '1:253230272977:ios:4309f5ed37c6a5c98850f0',
    messagingSenderId: '253230272977',
    projectId: 'chatapp-d3701',
    storageBucket: 'chatapp-d3701.appspot.com',
    iosBundleId: 'com.example.chatapp1',
  );
}
