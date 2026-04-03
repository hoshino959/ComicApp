import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  Future<void> loadTheme() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      final prefs = await SharedPreferences.getInstance();
      String? theme = prefs.getString("theme");
      if (theme == "dark") {
        themeMode = ThemeMode.dark;
      } else {
        themeMode = ThemeMode.light;
      }
      notifyListeners();
      return;
    }

    var doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get();

    String theme = doc.data()!["theme"];
    if (theme == "light") {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    var user = FirebaseAuth.instance.currentUser;

    String newTheme = themeMode == ThemeMode.dark ? "light" : "dark";

    themeMode = newTheme == "dark" ? ThemeMode.dark : ThemeMode.light;

    if (user == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("theme", newTheme);
    } else {
      await FirebaseFirestore.instance.collection("Users").doc(user.uid).update(
        {"theme": newTheme},
      );
    }
    notifyListeners();
  }
}
