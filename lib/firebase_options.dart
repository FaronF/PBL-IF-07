import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

// FirebaseOptions untuk web
FirebaseOptions get firebaseOptions {
  if (kIsWeb) {
    return const FirebaseOptions(
      apiKey: "AIzaSyDEfBtaQnT6s2xXiA6hj9bXXUiEdhuHvoc",
      projectId: "pbl-if-07-a80a9",
      storageBucket: "pbl-if-07-a80a9.appspot.com",
      messagingSenderId: "982195135418",
      appId: "1:982195135418:android:1e98ea88f921faa5203383",
    );
  } else {
    // Kembalikan konfigurasi FirebaseOptions untuk platform lain (Android/iOS)
    return const FirebaseOptions(
      apiKey: "AIzaSyDEfBtaQnT6s2xXiA6hj9bXXUiEdhuHvoc",
      projectId: "pbl-if-07-a80a9",
      storageBucket: "pbl-if-07-a80a9.appspot.com",
      messagingSenderId: "982195135418",
      appId: "1:982195135418:android:1e98ea88f921faa5203383",
    );
  }
}
