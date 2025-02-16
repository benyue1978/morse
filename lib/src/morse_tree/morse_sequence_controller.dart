import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'morse_audio_service.dart';
import 'morse_constants.dart';

class MorseSequenceController extends ChangeNotifier {
  static const int timeUnit = MorseConstants.timeUnit;
  static const int _elementGap = MorseConstants.gapDuration;
  static const int _letterGap = 3 * timeUnit;
  static const int _wordGap = 7 * timeUnit;
  
  final void Function(String letter) onLetterUpdate;
  final void Function(String morse) onMorseUpdate;
  final void Function(List<String> path) onPathUpdate;

  final Queue<_MorseEntry> _queue = Queue();
  final List<String> _morseHistory = [];
  String _displayText = '';
  bool _isProcessing = false;
  String _currentMorse = '';
  
  final MorseAudioService _audioService = MorseAudioService();
  int _activeIndex = -1;  // 添加高亮索引

  MorseSequenceController({
    required this.onLetterUpdate,
    required this.onMorseUpdate,
    required this.onPathUpdate,
  }) {
    _audioService.init();
  }

  // 添加字母到队列
  void addLetter(String letter, List<String> path) {
    if (letter == ' ') {
      // 处理空格
      _queue.add(_MorseEntry(' ', []));
      _displayText += ' ';
      _updateLetterDisplay();
    } else {
      _queue.add(_MorseEntry(letter, path));
      _displayText += letter;
      _updateLetterDisplay();
    }
    
    if (!_isProcessing) {
      _processQueue();
    }
  }

  // 处理队列
  Future<void> _processQueue() async {
    if (_queue.isEmpty) {
      _isProcessing = false;
      _activeIndex = -1;  // 重置高亮索引
      _updateLetterDisplay();
      return;
    }

    _isProcessing = true;
    final entry = _queue.removeFirst();
    _activeIndex = _displayText.length - _queue.length - 1;  // 更新高亮索引
    _updateLetterDisplay();
    
    await _processMorseCode(entry);
    _processQueue();
  }

  // 处理单个字母的摩尔斯码
  Future<void> _processMorseCode(_MorseEntry entry) async {
    if (entry.letter == ' ') {
      _morseHistory.add('   ');
      _updateMorseHistory();
      await Future.delayed(Duration(milliseconds: _wordGap));
      return;
    }

    String partialMorse = '';
    
    for (int i = 0; i < entry.path.length; i++) {
      final element = entry.path[i];
      onPathUpdate(entry.path.sublist(0, i + 1));
      
      if (element == 'dit') {
        await _audioService.playDit();
      } else {
        await _audioService.playDah();
      }

      partialMorse += element == 'dit' ? '.' : '-';
      _updateMorseDisplay(partialMorse);

      // 在元素之间添加间隔
      if (i < entry.path.length - 1) {
        await Future.delayed(Duration(milliseconds: _elementGap));
      }
    }

    await Future.delayed(Duration(milliseconds: _letterGap));
    onPathUpdate([]);
    _morseHistory.add(partialMorse);
    _updateMorseHistory();
  }

  void _updateLetterDisplay() {
    if (_activeIndex >= 0 && _activeIndex < _displayText.length) {
      onLetterUpdate('$_displayText|$_activeIndex');  // 添加高亮索引
    } else {
      onLetterUpdate(_displayText);
    }
  }

  void _updateMorseDisplay(String morse) {
    if (_currentMorse.isEmpty) {
      onMorseUpdate(morse);
    } else {
      onMorseUpdate('$_currentMorse   $morse');
    }
  }

  void _updateMorseHistory() {
    _currentMorse = _morseHistory.join('   ');
    onMorseUpdate(_currentMorse);
  }

  void clear() {
    _queue.clear();
    _morseHistory.clear();
    _displayText = '';
    _currentMorse = '';
    _isProcessing = false;
    _activeIndex = -1;  // 重置高亮索引
    
    onLetterUpdate('');
    onMorseUpdate('');
    onPathUpdate([]);
  }

  @override
  void dispose() {
    _queue.clear();
    _audioService.dispose();
    super.dispose();
  }
}

class _MorseEntry {
  final String letter;
  final List<String> path;

  _MorseEntry(this.letter, this.path);
} 