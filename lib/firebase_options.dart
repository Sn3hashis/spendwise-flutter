import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTaxGnDPxgoYaf9QVL6y45JHpRbIif4w4',
    appId: '1:228590481963:android:e5c992072d1f465189f06e',
    messagingSenderId: '228590481963',
    projectId: 'spendwise-6e665',
    storageBucket: 'spendwise-6e665.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0tX4sKy3yNLwqu8l5K8Im3wdctbVe4Hs',
    appId: '1:228590481963:ios:0af12f997287f2fc89f06e',
    messagingSenderId: '228590481963',
    projectId: 'spendwise-6e665',
    storageBucket: 'spendwise-6e665.firebasestorage.app',
    androidClientId: '228590481963-1h2mbe0sb22aoovsfncgostf4114865c.apps.googleusercontent.com',
    iosClientId: '228590481963-r5eatlllpdcus2bc4qv4jdumf7ici3id.apps.googleusercontent.com',
    iosBundleId: 'com.example.spendwise',
  );
} 