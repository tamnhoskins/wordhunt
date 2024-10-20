import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wordhunt/word_search_generator.dart';

class WordSearchHome extends StatefulWidget {
  @override
  _WordSearchHomeState createState() => _WordSearchHomeState();
}

class _WordSearchHomeState extends State<WordSearchHome> {
  final WordSearchGenerator _generator = WordSearchGenerator(10, 10);
  List<String> _words = [];
  List<List<String>> _grid = [];

  // Function to import words from a file
  Future<void> _importWords() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      List<String> lines = await file.readAsLines();
      setState(() {
        _words = lines;
      });
    }
  }

  int _numRows = 10;
  int _numCols = 10;

  // Set grid size based on screen dimensions
  void _setGridSize() {
    // Get the screen size
    double screenWidth = _availableWidth - 16.0;
    double screenHeight = (_availableHeight * 0.75) - 16.0;

    // Set minimum cell size (e.g., 30 pixels)
    double minCellSize = 30;

    // Calculate maximum rows and columns based on screen size
    _numRows = (screenHeight / minCellSize).floor();
    _numCols = (screenWidth / minCellSize).floor();

    // Ensure a minimum of 5 rows and 5 columns
    _numRows = max(_numRows, 5);
    _numCols = max(_numCols, 5);
  }

  // Function to generate word search puzzle
  void _generatePuzzle() {
    _words = [
      "snack",
      "bench",
      "thick",
      "plot",
      "trend",
      "habit",
      "insect",
      "subject",
      "crush",
      "judge",
      "spot",
      "split",
      "problem",
      "dentist",
      "hidden",
      "publish",
      "glad",
      "patch",
      "chest",
      "clock",
      "napkin",
      "kitten",
      "panic",
      "upset",
      "skunk",
      "spring",
      "trash",
      "spread",
      "absent",
      "contest",
      "plastic",
      "zigzag"
    ];
    print("Words size = ${_words.length} rows = $_numRows, col = $_numCols");
    _setGridSize();
    setState(() {
      _generator.fillGrid(_words, _numRows, _numCols);
      _grid = _generator.grid;
      _colors = _generator.colors;
      _currentWords = _generator.currentWords;
      _numRows = _generator.numRows;
      _numCols = _generator.numCols;
    });
  }

  List<List<Color>> _colors = [];
  List<String> _currentWords = [];

  bool _showAnswer = false;
  double _availableHeight = 0.0;
  double _availableWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Word Hunt"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _generatePuzzle,
          ),
          IconButton(
            icon: _showAnswer == false
                ? Icon(Icons.remove_red_eye_outlined)
                : Icon(Icons.clear),
            onPressed: () => setState(() {
              _showAnswer = !_showAnswer;
            }),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _availableHeight = constraints.maxHeight;
          _availableWidth = constraints.maxWidth;

          // Calculate 75% for grid and 25% for word list
          double gridHeight = _availableHeight * 0.75;
          double wordListHeight = _availableHeight * 0.25;
          return Column(
            children: [
              // Word search grid (75% of screen)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    // Add a border
                    color: Colors.blue, // Border color
                    width: 3.0, // Border width
                  ),
                  borderRadius:
                      BorderRadius.circular(8), // Optional: rounded corners
                ),
                height: gridHeight,
                width: _availableWidth,
                child: _grid.isNotEmpty ? _buildGrid() : Text("No Puzzle"),
              ),
              // Word list (25% of screen)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    // Add a border
                    color: Colors.green, // Border color
                    width: 3.0, // Border width
                  ),
                  borderRadius:
                      BorderRadius.circular(8), // Optional: rounded corners
                ),
                height: wordListHeight,
                width: _availableWidth,
                child: _buildWordList(wordListHeight),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _numCols,
            childAspectRatio: 1.0,
          ),
          itemCount: _numRows * _numCols,
          itemBuilder: (context, index) {
            int row = index ~/ _numCols;
            int col = index % _numCols;
            return GridTile(
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Center(
                  child: Text(
                    _grid[row][col],
                    style: TextStyle(
                        fontSize: 20,
                        color: _showAnswer == false
                            ? Colors.black
                            : _colors[row][col]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double calculateRowHeight() {
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight <= 600) {
      // Small screens (mobile)
      return 40.0;
    } else if (screenHeight <= 1200) {
      // Medium screens (tablets)
      return 50.0;
    } else {
      // Large screens (desktop)
      return 60.0;
    }
  }

  Widget _buildWordList(double wordListHeight) {
    final double rowHeight =
        calculateRowHeight(); // Adjust as needed for better fit
    final int numberOfRows = ((wordListHeight - 16.0) / rowHeight)
        .floor(); // Calculate number of rows

    return GridView.builder(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: numberOfRows, // Number of rows
        childAspectRatio: 0.5, // Adjust aspect ratio of the grid items
      ),
      itemCount: _currentWords.length,
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            _currentWords[index],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
