import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:soundpool/soundpool.dart';
import 'morse_constants.dart';

class MorseAudioService {
  static const double frequency = MorseConstants.frequency;
  static const int sampleRate = MorseConstants.sampleRate;
  static const double amplitude = MorseConstants.amplitude;

  late final Soundpool _pool;
  bool _isReady = false;
  int? _ditId;
  int? _dahId;

  Uint8List _generateSineWaveData(double durationMs, {bool silent = false}) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final rawData = List<int>.filled(numSamples * 2, 0);

    if (!silent) {
      for (int i = 0; i < numSamples; i++) {
        final t = i / sampleRate;
        final sample = (amplitude * math.sin(2 * math.pi * frequency * t) * 32767).round();
        // 写入16位PCM数据（小端序）
        rawData[i * 2] = sample & 0xFF;
        rawData[i * 2 + 1] = (sample >> 8) & 0xFF;
      }
    }

    return Uint8List.fromList(rawData);
  }

  ByteData _generateWavFile(double durationMs, {bool silent = false}) {
    final pcmData = _generateSineWaveData(durationMs, silent: silent);
    final buffer = ByteData(44 + pcmData.length);

    // RIFF header
    buffer.setUint8(0, 0x52); // 'R'
    buffer.setUint8(1, 0x49); // 'I'
    buffer.setUint8(2, 0x46); // 'F'
    buffer.setUint8(3, 0x46); // 'F'
    buffer.setUint8(4, (44 + pcmData.length) & 0xFF);
    buffer.setUint8(5, ((44 + pcmData.length) >> 8) & 0xFF);
    buffer.setUint8(6, ((44 + pcmData.length) >> 16) & 0xFF);
    buffer.setUint8(7, ((44 + pcmData.length) >> 24) & 0xFF);
    buffer.setUint8(8, 0x57);  // 'W'
    buffer.setUint8(9, 0x41);  // 'A'
    buffer.setUint8(10, 0x56); // 'V'
    buffer.setUint8(11, 0x45); // 'E'

    // fmt chunk
    buffer.setUint8(12, 0x66); // 'f'
    buffer.setUint8(13, 0x6D); // 'm'
    buffer.setUint8(14, 0x74); // 't'
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint8(16, 16);   // fmt chunk size
    buffer.setUint8(17, 0);
    buffer.setUint8(18, 0);
    buffer.setUint8(19, 0);
    buffer.setUint8(20, 1);    // PCM format
    buffer.setUint8(21, 0);
    buffer.setUint8(22, 1);    // mono
    buffer.setUint8(23, 0);
    // sample rate
    buffer.setUint8(24, (sampleRate & 0xFF).toInt());
    buffer.setUint8(25, ((sampleRate >> 8) & 0xFF).toInt());
    buffer.setUint8(26, ((sampleRate >> 16) & 0xFF).toInt());
    buffer.setUint8(27, ((sampleRate >> 24) & 0xFF).toInt());
    // byte rate
    final byteRate = sampleRate * 2;
    buffer.setUint8(28, byteRate & 0xFF);
    buffer.setUint8(29, (byteRate >> 8) & 0xFF);
    buffer.setUint8(30, (byteRate >> 16) & 0xFF);
    buffer.setUint8(31, (byteRate >> 24) & 0xFF);
    buffer.setUint8(32, 2);    // block align
    buffer.setUint8(33, 0);
    buffer.setUint8(34, 16);   // bits per sample
    buffer.setUint8(35, 0);

    // data chunk
    buffer.setUint8(36, 0x64); // 'd'
    buffer.setUint8(37, 0x61); // 'a'
    buffer.setUint8(38, 0x74); // 't'
    buffer.setUint8(39, 0x61); // 'a'
    buffer.setUint8(40, pcmData.length & 0xFF);
    buffer.setUint8(41, (pcmData.length >> 8) & 0xFF);
    buffer.setUint8(42, (pcmData.length >> 16) & 0xFF);
    buffer.setUint8(43, (pcmData.length >> 24) & 0xFF);

    // 复制 PCM 数据
    for (int i = 0; i < pcmData.length; i++) {
      buffer.setUint8(44 + i, pcmData[i]);
    }

    return buffer;
  }

  Future<void> init() async {
    try {
      _pool = Soundpool.fromOptions(
        options: SoundpoolOptions(streamType: StreamType.music)
      );
      
      final ditWav = _generateWavFile(MorseConstants.ditDuration.toDouble());
      final dahWav = _generateWavFile(MorseConstants.dahDuration.toDouble());

      _ditId = await _pool.load(ditWav);
      _dahId = await _pool.load(dahWav);
      
      _isReady = true;
    } catch (e) {
      print('音频初始化错误: $e');
    }
  }

  Future<void> playDit() async {
    if (!_isReady || _ditId == null) return;
    try {
      final streamId = await _pool.play(_ditId!);
      await Future.delayed(Duration(milliseconds: MorseConstants.ditDuration));
      await _pool.stop(streamId);
    } catch (e) {
      print('播放 dit 失败: $e');
    }
  }

  Future<void> playDah() async {
    if (!_isReady || _dahId == null) return;
    try {
      final streamId = await _pool.play(_dahId!);
      await Future.delayed(Duration(milliseconds: MorseConstants.dahDuration));
      await _pool.stop(streamId);
    } catch (e) {
      print('播放 dah 失败: $e');
    }
  }

  void dispose() {
    _pool.dispose();
  }
}
