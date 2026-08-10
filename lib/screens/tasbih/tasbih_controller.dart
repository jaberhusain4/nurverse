import 'package:flutter/foundation.dart';

class TasbihController extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  final int target = 33;

  void increment() {
    _count++;

    if (_count > target) {
      _count = 1;
    }

    notifyListeners();
  }

  void reset() {
    _count = 0;

    notifyListeners();
  }

  double get progress {
    return _count / target;
  }
}
