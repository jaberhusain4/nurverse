import 'package:flutter/material.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isPlaying = false;
  String? _currentAudioUrl;
  String _selectedReciter = 'Mishary Rashid Alafasy';
  double _playbackSpeed = 1.0;
  Duration _currentPosition = Duration.zero;
  final Duration _totalDuration = Duration.zero;

  // গেটারস (Getters)
  bool get isPlaying => _isPlaying;
  String? get currentAudioUrl => _currentAudioUrl;
  String get selectedReciter => _selectedReciter;
  double get playbackSpeed => _playbackSpeed;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  /// অডিও প্লে করা
  Future<void> playAudio(String url) async {
    _currentAudioUrl = url;
    _isPlaying = true;
    notifyListeners();
    debugPrint("Playing audio: $url with reciter: $_selectedReciter");
  }

  /// অডিও পজ করা
  Future<void> pauseAudio() async {
    _isPlaying = false;
    notifyListeners();
    debugPrint("Audio paused");
  }

  /// অডিও স্টপ করা
  Future<void> stopAudio() async {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
    debugPrint("Audio stopped");
  }

  /// ক্বারী (Reciter) পরিবর্তন করা
  void setReciter(String reciterName) {
    _selectedReciter = reciterName;
    notifyListeners();
    debugPrint("Selected reciter: $reciterName");
  }

  /// প্লেইং স্পিড পরিবর্তন (0.5x, 1.0x, 1.5x, 2.0x)
  void setSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  /// নির্দিষ্ট সময়ের পজিশনে যাওয়া (Seek)
  void seekTo(Duration position) {
    _currentPosition = position;
    notifyListeners();
  }
}
