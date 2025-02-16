import 'package:audioplayers/audioplayers.dart';

class MorseAudioService {
  final AudioPlayer _ditPlayer = AudioPlayer();
  final AudioPlayer _dahPlayer = AudioPlayer();
  final AudioPlayer _gapPlayer = AudioPlayer();
  bool _isReady = false;

  Future<void> init() async {
    try {
      await _ditPlayer.setSource(AssetSource('audio/dit.wav'));
      await _dahPlayer.setSource(AssetSource('audio/dah.wav'));
      await _gapPlayer.setSource(AssetSource('audio/gap.wav'));
      
      await _ditPlayer.setVolume(0.5);
      await _dahPlayer.setVolume(0.5);
      await _gapPlayer.setVolume(0.5);
      
      _isReady = true;
    } catch (e) {
      print('音频初始化错误: $e');
    }
  }

  Future<void> playDit() async {
    if (!_isReady) return;
    try {
      await _ditPlayer.seek(Duration.zero);
      await _ditPlayer.resume();
    } catch (e) {
      print('播放 dit 失败: $e');
    }
  }

  Future<void> playDah() async {
    if (!_isReady) return;
    try {
      await _dahPlayer.seek(Duration.zero);
      await _dahPlayer.resume();
    } catch (e) {
      print('播放 dah 失败: $e');
    }
  }

  Future<void> playGap() async {
    if (!_isReady) return;
    try {
      await _gapPlayer.seek(Duration.zero);
      await _gapPlayer.resume();
    } catch (e) {
      print('播放 gap 失败: $e');
    }
  }

  void dispose() {
    _ditPlayer.dispose();
    _dahPlayer.dispose();
    _gapPlayer.dispose();
  }
} 