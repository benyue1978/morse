import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'morse_painter.dart';
import 'morse_service.dart';

class MorseTreeView extends StatefulWidget {
  const MorseTreeView({super.key});

  @override
  State<MorseTreeView> createState() => _MorseTreeViewState();
}

class _MorseTreeViewState extends State<MorseTreeView> {
  final MorseService _morseService = MorseService();
  List<String> _highlightPath = [];
  String _currentLetter = '';
  String _currentMorse = '';

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('莫尔斯电码', style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            Expanded(child: _buildMorseTree()),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMorseTree() {
    return Center(
      child: CustomPaint(
        painter: MorseTreePainter(highlightPath: _highlightPath),
        size: const Size(1200, 800),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '按键: $_currentLetter',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(width: 40),
          SizedBox(
            width: 200,
            child: Text(
              '摩斯码: $_currentMorse',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey.keyLabel.toUpperCase();
      final path = _morseService.findPath(key);
      if (path.isNotEmpty) {
        _startAnimation(key, path);
      }
    }
  }

  void _startAnimation(String letter, List<String> path) {
    setState(() {
      _currentLetter = letter;
      _currentMorse = '';
      _highlightPath = [];
    });

    for (int i = 0; i < path.length; i++) {
      Future.delayed(
        Duration(milliseconds: i * MorseService.timeUnit * 2),
        () => setState(() {
          _highlightPath = path.sublist(0, i + 1);
          _currentMorse += path[i] == 'dit' ? '.' : '-';
        }),
      );
    }

    Future.delayed(
      Duration(milliseconds: path.length * MorseService.timeUnit * 2 + MorseService.timeUnit),
      () => setState(() => _highlightPath = []),
    );
  }
} 