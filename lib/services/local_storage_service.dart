import 'package:shared_preferences/shared_preferences.dart'; 
import 'dart:convert'; 

class LocalStorageService {
  static SharedPreferences? _preferences; 
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }
  String? getString(String key) {
    return _preferences?.getString(key);
  }
  Future<void> saveBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }
  Future<void> saveList<T>(String key, List<T> list, Function(T) toJson) async {
    final String encodedList = json.encode(list.map((item) => toJson(item)).toList());
    await _preferences?.setString(key, encodedList);
  }
  List<T> getList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final String? encodedList = _preferences?.getString(key);
    if (encodedList == null) {
      return []; 
    }
    final List<dynamic> decodedList = json.decode(encodedList);
    return decodedList.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }
  Future<void> clearAll() async {
    await _preferences?.clear();
  }
}
