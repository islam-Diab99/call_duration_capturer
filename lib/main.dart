import 'package:call_duration_task/screens/last_call_duration_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Last Call Duration App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LastCallDurationPage(),
    );
  }
}
