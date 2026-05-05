import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'DefaultFirebaseOptions non configure. '
      'Executez : flutterfire configure',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAcs7aARnlIofaxTWrzrxqlKmulmv-KoEs',
    appId: '1:843797762388:web:7144ab45940ccc394ef8c1',
    messagingSenderId: '843797762388',
    projectId: 'ehbien-lotto-admin',
    authDomain: 'ehbien-lotto-admin.firebaseapp.com',
    storageBucket: 'ehbien-lotto-admin.firebasestorage.app',
    measurementId: 'G-LC945VFWHL',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId:             '1:000000000000:ios:XXXXXXXXXXXXXXXXXXXXXXXX',
    messagingSenderId: '000000000000',
    projectId:         'ehbien-lotto',
    storageBucket:     'ehbien-lotto.appspot.com',
    iosClientId:       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com',
    iosBundleId:       'com.example.ehbienLottoAdmin',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId:             '1:000000000000:android:XXXXXXXXXXXXXXXXXXXXXXXX',
    messagingSenderId: '000000000000',
    projectId:         'ehbien-lotto',
    storageBucket:     'ehbien-lotto.appspot.com',
  );
}