import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBa9Qk08Tvj6Tx7J80zJBxsgVB69hYJHWQ',
    appId: '1:534758324230:web:568cb90bd49adfa23feb87',
    messagingSenderId: '534758324230',
    projectId: 'restofind-8eb68',
    authDomain: 'restofind-8eb68.firebaseapp.com',
    storageBucket: 'restofind-8eb68.firebasestorage.app',
    measurementId: 'G-8VS4FC1FMB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeeTNCEmDudF_JrX9I2xve74GN2eBfuxU',
    appId: '1:534758324230:android:94a7ac508b2339433feb87',
    messagingSenderId: '534758324230',
    projectId: 'restofind-8eb68',
    storageBucket: 'restofind-8eb68.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD17ZMeFm4ck67GLRI1oCisxqkPGyLKDXM',
    appId: '1:534758324230:ios:72c1d4e260f865b73feb87',
    messagingSenderId: '534758324230',
    projectId: 'restofind-8eb68',
    storageBucket: 'restofind-8eb68.firebasestorage.app',
    iosBundleId: 'com.example.restofind',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD17ZMeFm4ck67GLRI1oCisxqkPGyLKDXM',
    appId: '1:534758324230:ios:72c1d4e260f865b73feb87',
    messagingSenderId: '534758324230',
    projectId: 'restofind-8eb68',
    storageBucket: 'restofind-8eb68.firebasestorage.app',
    iosBundleId: 'com.example.restofind',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZv3MNfNSDgPnAzUGXbsQkTUrMSo7yhtk',
    appId: '1:534758324230:web:24b5870ffa78ec6f3feb87',
    messagingSenderId: '534758324230',
    projectId: 'restofind-8eb68',
    authDomain: 'restofind-8eb68.firebaseapp.com',
    storageBucket: 'restofind-8eb68.firebasestorage.app',
    measurementId: 'G-Y8MMH0B97S',
  );

}