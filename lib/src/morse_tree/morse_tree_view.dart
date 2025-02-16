import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'morse_painter.dart';
import 'morse_service.dart';
import 'morse_sequence_controller.dart';

class MorseTreeView extends StatefulWidget {
  const MorseTreeView({super.key});

  @override
  State<MorseTreeView> createState() => _MorseTreeViewState();
}

class _MorseTreeViewState extends State<MorseTreeView> {
  final MorseService _morseService = MorseService();
  late final MorseSequenceController _sequenceController;
  List<String> _highlightPath = [];
  String _letters = '';
  String _currentMorse = '';

  @override
  void initState() {
    super.initState();
    _sequenceController = MorseSequenceController(
      onLetterUpdate: (letter) => setState(() => _letters = letter),
      onMorseUpdate: (morse) => setState(() => _currentMorse = morse),
      onPathUpdate: (path) => setState(() => _highlightPath = path),
    );
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) => KeyEventResult.handled,
      child: KeyboardListener(
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 700,
                child: _buildLetterText(),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () => _sequenceController.clear(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 800,
            child: Text(
              '摩尔斯码: $_currentMorse',
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

  Widget _buildLetterText() {
    final parts = _letters.split('|');
    if (parts.length != 2) {
      return Text(
        '输入: ${parts[0]}',
        style: const TextStyle(color: Colors.white, fontSize: 24),
      );
    }

    final text = parts[0];
    final activeIndex = int.tryParse(parts[1]) ?? -1;

    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: '输入: ',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          ...text.characters.mapIndexed((index, char) => TextSpan(
            text: char,
            style: TextStyle(
              color: index == activeIndex ? Colors.amber : Colors.white,
              fontSize: 24,
            ),
          )),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey.keyLabel.toUpperCase();
      final path = _morseService.findPath(key);
      if (path.isNotEmpty) {
        _sequenceController.addLetter(key, path);
      }
    }
  }
} 