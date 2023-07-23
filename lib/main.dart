import 'dart:async';

import 'package:camera/camera.dart';
import 'package:detection/Screen/Login.dart';
import 'package:detection/Screen/animated_page.dart';
import 'package:detection/Screen/botttom_nav_bar.dart';
import 'package:detection/Screen/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:detection/Screen/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

//late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    //cameras = await availableCameras();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(MyApp());
  } catch (e) {}
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SharedPreferences data;
  bool _isLoggedIn = false;

  Future checkIfLogin() async {
    data = await SharedPreferences.getInstance();
    bool? _val = data.getBool("login");
    if (_val == true) {
      setState(() {
        _isLoggedIn = !_isLoggedIn;
      });
    }
  }

  @override
  void initState() {
    checkIfLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? const Bottom_Nav_Bar() : const Login(),
      routes: {
        '/success': (context) => const Bottom_Nav_Bar(),
      },
    );
  }
}
