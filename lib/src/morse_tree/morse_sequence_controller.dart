import 'dart:async';
import 'package:flutter/foundation.dart';

class MorseSequenceController {
  static const int timeUnit = 50;  // 修改为 100ms
  
  final void Function(String letter) onLetterUpdate;
  final void Function(String morse) onMorseUpdate;
  final void Function(List<String> path) onPathUpdate;

  Timer? _sequenceTimer;
  final List<_MorseEntry> _sequence = [];
  final List<String> _morseHistory = [];
  String _displayText = '';
  int _activeIndex = -1;
  bool _isProcessing = false;
  String _currentMorse = '';  // 添加当前处理的摩尔斯码字符串

  MorseSequenceController({
    required this.onLetterUpdate,
    required this.onMorseUpdate,
    required this.onPathUpdate,
  });

  void addEntry(String letter, List<String> path) {
    _sequence.add(_MorseEntry(letter, path));
    _displayText += letter;
    _updateLetterDisplay();
    
    String morse = path.map((e) => e == 'dit' ? '.' : '-').join('');
    _morseHistory.add(morse);
    
    if (!_isProcessing) {
      _processNextEntry();
    }
  }

  void _updateLetterDisplay() {
    if (_activeIndex >= 0 && _activeIndex < _displayText.length) {
      onLetterUpdate('$_displayText|$_activeIndex');
    } else {
      onLetterUpdate(_displayText);
    }
  }

  void _processNextEntry() {
    if (_sequence.isEmpty) {
      _isProcessing = false;
      _activeIndex = -1;
      _updateLetterDisplay();
      return;
    }

    _isProcessing = true;
    final entry = _sequence.removeAt(0);
    _activeIndex = _displayText.length - _sequence.length - 1;
    _updateLetterDisplay();

    String partialMorse = '';
    List<String> currentPath = [];
    int totalDelay = 0;

    // 处理每个dit/dah
    for (int i = 0; i < entry.path.length; i++) {
      final element = entry.path[i];
      
      _scheduleUpdate(totalDelay, () {
        currentPath = entry.path.sublist(0, i + 1);
        onPathUpdate(currentPath);
      });

      _scheduleUpdate(totalDelay, () {
        partialMorse += element == 'dit' ? '.' : '-';
        // 更新当前完整的摩尔斯码显示
        if (_currentMorse.isNotEmpty) {
          onMorseUpdate('$_currentMorse   $partialMorse');
        } else {
          onMorseUpdate(partialMorse);
        }
      });

      totalDelay += element == 'dit' ? timeUnit : timeUnit * 3;
      if (i < entry.path.length - 1) {
        totalDelay += timeUnit;
      }
    }

    totalDelay += timeUnit * 3;

    _sequenceTimer = Timer(Duration(milliseconds: totalDelay), () {
      onPathUpdate([]);
      // 更新完整的摩尔斯码字符串
      if (_currentMorse.isEmpty) {
        _currentMorse = entry.path.map((e) => e == 'dit' ? '.' : '-').join('');
      } else {
        _currentMorse = '$_currentMorse   ${entry.path.map((e) => e == 'dit' ? '.' : '-').join('')}';
      }
      _processNextEntry();
    });
  }

  void dispose() {
    _sequenceTimer?.cancel();
    _sequence.clear();
    _morseHistory.clear();
    _displayText = '';
    _activeIndex = -1;
    _currentMorse = '';
  }

  void _scheduleUpdate(int delay, VoidCallback callback) {
    Timer(Duration(milliseconds: delay), callback);
  }

  void clear() {
    _sequenceTimer?.cancel();
    _sequence.clear();
    _morseHistory.clear();
    _displayText = '';
    _activeIndex = -1;
    _currentMorse = '';
    _isProcessing = false;
    
    onLetterUpdate('');
    onMorseUpdate('');
    onPathUpdate([]);
  }
}

class _MorseEntry {
  final String letter;
  final List<String> path;

  _MorseEntry(this.letter, this.path);
} 