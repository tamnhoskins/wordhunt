import 'dart:math';
import 'package:flutter/material.dart';

class WordSearchGrid extends StatefulWidget {
  final List<String> words;
  final int gridSizeN; // Number of rows
  final int gridSizeM; // Number of columns

  WordSearchGrid({required this.words, required this.gridSizeN, required this.gridSizeM});

  @override
  _WordSearchGridState createState() => _WordSearchGridState();
}

class _WordSearchGridState extends State<WordSearchGrid> {
  late List<List<String>> grid;
  List<String> currentWords = [];

  @override
  void initState() {
    super.initState();
    _validateAndGenerateGrid(widget.words);
  }

  // Validates if the grid size can fit all words
  void _validateAndGenerateGrid(List<String> words) {
    int availableCells = widget.gridSizeN * widget.gridSizeM; // Total grid cells
    int totalCharacters = words.fold(0, (sum, word) => sum + word.length); // Total word length

    if (totalCharacters > availableCells) {
      // If the words can't fit in the grid, split them into chunks that fit
      _splitWordsIntoChunks(words, availableCells);
    } else {
      // If words fit, generate the grid
      _generateGrid(words);
    }
  }

  // Split words into chunks that can fit in the grid
  void _splitWordsIntoChunks(List<String> words, int availableCells) {
    List<List<String>> wordChunks = [];
    List<String> currentChunk = [];
    int currentChunkLength = 0;

    for (String word in words) {
      if (currentChunkLength + word.length <= availableCells) {
        currentChunk.add(word);
        currentChunkLength += word.length;
      } else {
        wordChunks.add(currentChunk); // Save the current chunk
        currentChunk = [word]; // Start a new chunk
        currentChunkLength = word.length;
      }
    }

    // Add the final chunk
    if (currentChunk.isNotEmpty) {
      wordChunks.add(currentChunk);
    }

    // Handle one chunk at a time (show the first chunk initially)
    setState(() {
      currentWords = wordChunks.first;
      _generateGrid(currentWords);
    });

    // You could add a UI to switch between different word chunks if needed
  }

  void _generateGrid(List<String> words) {
    int N = widget.gridSizeN;
    int M = widget.gridSizeM;

    // Initialize an empty grid of NxM
    grid = List.generate(N, (_) => List.generate(M, (_) => ' '));

    // Fill the grid with words and random letters
    _fillGridWithWords(words);
  }

  void _fillGridWithWords(List<String> words) {
    List<String> directions = ["horizontal", "vertical", "diagonal_forward", "diagonal_backward"];
    Random _random = Random();

    for (String word in words) {
      bool placed = false;
      while (!placed) {
        String direction = directions[_random.nextInt(directions.length)];
        int row = _random.nextInt(widget.gridSizeN);
        int col = _random.nextInt(widget.gridSizeM);
        if (_canPlaceWord(word, row, col, direction)) {
          _placeWord(word, row, col, direction);
          placed = true;
        }
      }
    }

    _fillEmptySpaces();
  }

  bool _canPlaceWord(String word, int row, int col, String direction) {
    int N = widget.gridSizeN;
    int M = widget.gridSizeM;

    if (direction == "horizontal" && col + word.length <= M) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row][col + i] != ' ' && grid[row][col + i] != word[i]) {
          return false;
        }
      }
      return true;
    } else if (direction == "vertical" && row + word.length <= N) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col] != ' ' && grid[row + i][col] != word[i]) {
          return false;
        }
      }
      return true;
    } else if (direction == "diagonal_forward" && row + word.length <= N && col + word.length <= M) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col + i] != ' ' && grid[row + i][col + i] != word[i]) {
          return false;
        }
      }
      return true;
    } else if (direction == "diagonal_backward" && row + word.length <= N && col - word.length >= -1) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col - i] != ' ' && grid[row + i][col - i] != word[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  void _placeWord(String word, int row, int col, String direction) {
    if (direction == "horizontal") {
      for (int i = 0; i < word.length; i++) {
        grid[row][col + i] = word[i];
      }
    } else if (direction == "vertical") {
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col] = word[i];
      }
    } else if (direction == "diagonal_forward") {
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col + i] = word[i];
      }
    } else if (direction == "diagonal_backward") {
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col - i] = word[i];
      }
    }
  }

  void _fillEmptySpaces() {
    Random _random = Random();
    for (int row = 0; row < widget.gridSizeN; row++) {
      for (int col = 0; col < widget.gridSizeM; col++) {
        if (grid[row][col] == ' ') {
          grid[row][col] = String.fromCharCode(65 + _random.nextInt(26)); // Random letter A-Z
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Word Search Grid"),
      ),
      body: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSizeM, // Number of columns = M
            childAspectRatio: 1.0, // Keep cells square
          ),
          itemCount: widget.gridSizeN * widget.gridSizeM, // Total cells in the grid
          itemBuilder: (context, index) {
            int row = index ~/ widget.gridSizeM;
            int col = index % widget.gridSizeM;
            return Container(
              margin: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: Text(
                  grid[row][col], // Display the character at grid[row][col]
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
