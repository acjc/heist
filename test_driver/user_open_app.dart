import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:heist/main.dart';

Future main() async {
  // This line enables the extension
  enableFlutterDriverExtension();

  // Call the `main()` of your app or call `runApp` with whatever widget
  // you are interested in testing.
  FirebaseOptions options = new FirebaseOptions(); //TODO - not in GitHub

  FirebaseApp app = await FirebaseApp.configure(name: 'name', options: options);
  Firestore firestore = new Firestore(app: app);
  runApp(new MyApp(firestore));
}
