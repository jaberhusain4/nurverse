import 'package:flutter/foundation.dart';

class TasbihController extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;

    notifyListeners();
  }

  void reset() {
    _count = 0;

    notifyListeners();
  }

  void decrement() {
    if (_count > 0) {
      _count--;

      notifyListeners();
    }
  }
}
