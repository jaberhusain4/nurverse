import 'package:shared_preferences/shared_preferences.dart';

class TasbihService {
  static const _countKey = 'tasbih_count';
  static const _targetKey = 'tasbih_target';

  Future<int> getCount() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_countKey) ?? 0;
  }

  Future<int> getTarget() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_targetKey) ?? 33;
  }

  Future<void> saveCount(int count) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_countKey, count);
  }

  Future<void> saveTarget(int target) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_targetKey, target);
  }

  Future<void> reset() => saveCount(0);
}
