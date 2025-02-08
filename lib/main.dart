import 'package:flutter/material.dart';
import 'src/morse_tree/morse_tree_view.dart';

void main() {
  runApp(const MorseTreeApp());
}

class MorseTreeApp extends StatelessWidget {
  const MorseTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse Code Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MorseTreeView(),
    );
  }
}
