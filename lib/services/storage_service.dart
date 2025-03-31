import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/button_model.dart';

class StorageService {
  static const String _key = 'buttons_data';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<List<ButtonModel>> getButtons() async {
    final String? data = _prefs.getString(_key);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => ButtonModel.fromJson(json)).toList();
  }

  Future<void> saveButtons(List<ButtonModel> buttons) async {
    final List<Map<String, dynamic>> jsonList =
        buttons.map((button) => button.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
