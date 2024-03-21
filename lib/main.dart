import 'package:flutter/material.dart';
import 'package:google_maps/Google%20Maps/Home.dart';

import 'package:google_maps/Google%20Maps/LatLongtoAddress.dart';
import 'package:google_maps/Google%20Maps/Search.dart';
import 'package:google_maps/Google%20Maps/getuserloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GetUserLoc(),
    );
  }
}
