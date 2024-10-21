import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class WordSearchGenerator {
  int numRows;
  int numCols;
  late List<List<String>> grid;
  late List<List<Color>> colors;
  final Random _random = Random();
  List<String> currentWords = [];

  WordSearchGenerator(this.numRows, this.numCols) {
    grid = List.generate(numRows, (_) => List.generate(numCols, (_) => ' '));
  }

  // Function to check if a word fits in the grid in the given direction
  bool _canPlaceWord(String word, int row, int col, String direction) {
    if (direction == "horizontal" && col + word.length <= numCols) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row][col + i] != ' ' && grid[row][col + i] != word[i]) {
          return false;
        }
      }
      return true;
    } else if (direction == "vertical" && row + word.length <= numRows) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col] != ' ' && grid[row + i][col] != word[i]) {
          return false;
        }
      }
      return true;
    } else if (direction == "diagonal_forward" && row + word.length <= numRows && col + word.length <= numCols) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col + i] != ' ' && grid[row + i][col + i] != word[i]) {
          return false;
        }
      }
      return true;
    } else if (direction == "diagonal_backward" && row + word.length <= numRows && col - word.length >= -1) {
      for (int i = 0; i < word.length; i++) {
        if (grid[row + i][col - i] != ' ' && grid[row + i][col - i] != word[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
  Color _generateRandomColor(Random random) {
    Color color;
    do {
      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    } while (_isColorTooLight(color));

    return color;
  }

  bool _isColorTooLight(Color color) {
    // Calculate the luminance using the formula
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.7; // Adjust the threshold as needed
  }
  // Function to place a word in the grid in the given direction
  void _placeWord(String word, int row, int col, String direction) {
    Color answerColor = _generateRandomColor(_random);
    if (direction == "horizontal") {
      for (int i = 0; i < word.length; i++) {
        grid[row][col + i] = word[i];
        colors[row][col + i] = answerColor;
      }
    } else if (direction == "vertical") {
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col] = word[i];
        colors[row + i][col] = answerColor;
      }
    } else if (direction == "diagonal_forward") {
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col + i] = word[i];
        colors[row + i][col + i] = answerColor;
      }
    } else if (direction == "diagonal_backward") {
      for (int i = 0; i < word.length; i++) {
        grid[row + i][col - i] = word[i];
        colors[row + i][col - i] = answerColor;
      }
    }
  }

  // Function to fill the grid with random letters in empty spaces
  void _fillEmptySpaces() {
    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        if (grid[row][col] == ' ') {
          String value = String.fromCharCode(65 + _random.nextInt(26));
          grid[row][col] = value; // Random letter A-Z
        }
      }
    }
  }

  int calculateGridSize(List<String> words) {
    print("***TAM:calculateGridSize words length = ${words.length}");
    // Calculate the total number of characters
    int totalCharacters = words.fold(0, (sum, word) => sum + word.length);

    // Calculate grid size using the padding factor (1.5) and square root formula
    int gridSize = (sqrt(1.5 * totalCharacters)).ceil();

    return gridSize;
  }

  // Randomly select words to fit in the grid
  List<String> _randomlySelectWords(List<String> words, int availableCells) {
    Random random = Random();
    List<String> selectedWords = [];
    int currentLength = 0;

    // Shuffle the words list to ensure randomness
    List<String> shuffledWords = List.from(words)..shuffle(random);

    for (String word in shuffledWords) {
      if (currentLength + word.length <= availableCells) {
        selectedWords.add(word.toUpperCase());
        currentLength += word.length;
      }
    }

    return selectedWords;
  }


  // Function to generate the word search grid with random word placement
  void fillGrid(List<String> words, int numRows, int numCols) {
    if(words.isEmpty) { return; }

    // Calculate the total number of cells available
    int availableCells = numRows * numCols;

    // Filter the words to only those that can fit in the grid
    List<String> filteredWords = words.where((word) => word.length <= numCols).toList();

    if (filteredWords.isEmpty) {
      // If no words fit, show an error or handle accordingly
      print("No words can fit in the grid!");
      return;
    }

    // Randomly select words from the filtered list until we reach the available cells limit
    List<String> currentWordsToUse = _randomlySelectWords(filteredWords, availableCells);

    // Reset the grid to an empty state before shuffling word placement
    int size = min(max(numRows, calculateGridSize(currentWordsToUse)), numCols);
    this.numRows = min(numRows, calculateGridSize(currentWordsToUse));
    this.numCols = max(this.numRows, numCols);
    grid = List.generate(this.numRows, (_) => List.generate(this.numCols, (_) => ' '));
    colors = List.generate(this.numRows, (_) => List.generate(this.numCols, (_) => Colors.black));
    currentWords.clear();
    List<String> directions = ["horizontal", "vertical", "diagonal_forward", "diagonal_backward"];

    print("_numRows = ${this.numRows}, $numRows numCols = ${this.numCols}, $numCols");
    for (String word in currentWordsToUse) {
      bool placed = false;
      int numTries = 0;
      while (!placed && numTries < 100) {
        String direction = directions[_random.nextInt(directions.length)];
        int row = _random.nextInt(this.numRows);
        int col = _random.nextInt(this.numCols);
        if (_canPlaceWord(word, row, col, direction)) {
          _placeWord(word, row, col, direction);
          placed = true;
          currentWords.add(word);
        }
        else {
          ++numTries;
        }
      }
    }

    // If no words were placed randomly, fallback to simple horizontal or vertical placements
    if (currentWords.isEmpty) {
      print('No words were placed randomly. Falling back to simple placement.');
      _placeWordsInSimpleLocations(currentWordsToUse, numRows, numCols);
    }

    _fillEmptySpaces();  // Fill remaining spaces with random letters
  }

  void _placeWordsInSimpleLocations(List<String> currentWordsToUse, int numRows, int numCols) {
    int row = 0;
    int col = 0;
    bool horizontal = true; // Start with horizontal placements

    for (int wordIndex = 0; wordIndex < currentWordsToUse.length; wordIndex++) {
      String word = currentWordsToUse[wordIndex];

      // Check if word fits horizontally
      if (horizontal && col + word.length <= numRows) {
        _placeWord(word, row, col, "horizontal"); // Place horizontally
        col += word.length + 1; // Move to the right
      }
      // If horizontal placement doesn't fit, switch to vertical placement
      else if (row + word.length <= numCols) {
        _placeWord(word, row, col, "vertical"); // Place vertically
        row += word.length + 1; // Move downwards
        col = 0; // Reset column for next word
        horizontal = !horizontal; // Toggle direction
      }
      // If both directions are full, stop placing words
      else {
        print('Not enough space for more words.');
        break;
      }
    }
  }
}
