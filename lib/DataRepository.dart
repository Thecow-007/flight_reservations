import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class DataRepository{
  static String? login;

  static EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

  static void loadEncrypted() async {
    DataRepository.login = await prefs.getString("login");

  }

  static void saveEncrypted(String login) async {
    await prefs.setString("login", login);
  }

  static void cleanData() async {
    await prefs.remove("login");

  }
}
