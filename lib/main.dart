import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wordhunt/word_search_home.dart';
// Import the backend logic

void main() {
  runApp(WordSearchApp());
}

class WordSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(1080,
            2400), // Design size based on your Figma design or target screen
        minTextAdapt: true,
        splitScreenMode: false,
        builder: (context, child) {
          return MaterialApp(
            home: WordSearchHome(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
