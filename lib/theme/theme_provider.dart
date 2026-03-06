import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  loadTheme() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      themeMode = ThemeMode.light;
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

  toggleTheme() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String newTheme = themeMode == ThemeMode.dark ? "light" : "dark";
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).update({
      "theme": newTheme,
    });
    themeMode = newTheme == "dark" ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
