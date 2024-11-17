import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart' show TargetPlatform;
import 'package:firebase_core/firebase_core.dart';

// ...

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

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
    apiKey: 'AIzaSyADMlwDndHyO9cecHHECLEY-vk8JsuHPhU',
    appId: '1:338590767004:web:8823a9b4ec520ec3539a59',
    messagingSenderId: '338590767004',
    projectId: 'transitai',
    authDomain: 'transitai.firebaseapp.com',
    storageBucket: 'transitai.firebasestorage.app',
    measurementId: 'G-5CSQLRH51M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvjfnfdE4KffeCV9AeoEmd1SfheXxzYXQ',
    appId: '1:338590767004:android:0adc4f4c9529b3ce539a59',
    messagingSenderId: '338590767004',
    projectId: 'transitai',
    storageBucket: 'transitai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcMSa459F8Kfm9xfzTKQJtLLloS4JIGks',
    appId: '1:338590767004:ios:c7905fa513f83bbd539a59',
    messagingSenderId: '338590767004',
    projectId: 'transitai',
    storageBucket: 'transitai.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDcMSa459F8Kfm9xfzTKQJtLLloS4JIGks',
    appId: '1:338590767004:ios:c7905fa513f83bbd539a59',
    messagingSenderId: '338590767004',
    projectId: 'transitai',
    storageBucket: 'transitai.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyADMlwDndHyO9cecHHECLEY-vk8JsuHPhU',
    appId: '1:338590767004:web:2b9b8254e55a59d1539a59',
    messagingSenderId: '338590767004',
    projectId: 'transitai',
    authDomain: 'transitai.firebaseapp.com',
    storageBucket: 'transitai.firebasestorage.app',
    measurementId: 'G-V4FPBBZ8LF',
  );

}