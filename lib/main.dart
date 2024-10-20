import 'package:flutter/material.dart';
import 'package:wordhunt/word_search_home.dart';
 // Import the backend logic

void main() {
  runApp(WordSearchApp());
}

class WordSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WordSearchHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}


