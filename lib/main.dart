import 'home.dart';
import 'login.dart';
import 'register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: "register",
      debugShowCheckedModeBanner: false,
      routes: {
        "register": (context) => RegisterScreen(),
        "login": (context) => LoginScreen(),
        "home": (context) => HomeScreen(),
     },
);
}
}