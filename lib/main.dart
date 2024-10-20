

import 'package:chatapp1/service/auth/auth_gate.dart';

import 'package:chatapp1/firebase_options.dart';
import 'package:chatapp1/pages/login_page.dart';
import 'package:chatapp1/theme/light_mode.dart';
import 'package:chatapp1/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import 'api/firebase_api.dart';

//final navigatorkey =GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseApi().initNotifications();
  runApp(  ChangeNotifierProvider(
    create:(context) => ThemeProvider(),
    child: MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:   AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}








