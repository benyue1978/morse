class MorseConstants {
  static const int timeUnit = 100;  // 基本时间单位 (ms)
  
  // 音频时长
  static const int ditDuration = timeUnit;      // 点的持续时间
  static const int dahDuration = 3 * timeUnit;  // 划的持续时间
  static const int gapDuration = timeUnit;      // 间隔持续时间
  
  // 音频参数
  static const double frequency = 550.0;  // 音频频率 (Hz)
  static const int sampleRate = 44100;    // 采样率
  static const double amplitude = 0.5;     // 音量
} 