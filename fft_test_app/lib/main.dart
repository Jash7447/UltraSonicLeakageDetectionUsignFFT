import 'package:flutter/material.dart';
//Importing the primary widget of our application in main.dart
import 'package:usld/screens/fft_imaging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //Calling the primary widget as the home 
      home: const FftImaging(),
    );
  }
}
