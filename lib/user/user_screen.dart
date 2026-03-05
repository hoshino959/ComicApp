import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/user/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/models/oklab.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return UserScreenState();
  }
}

String uid = FirebaseAuth.instance.currentUser!.uid;

class UserScreenState extends State<UserScreen> {
  bool? isDark;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  loadTheme() async {
    var doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get();
    String theme = doc.data()!["theme"];

    setState(() {
      if (theme == "light") {
        isDark = false;
      } else if (theme == "dark") {
        isDark = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkMode =
        isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final gradient = darkMode
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: 60),
                  //logoApp
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(height: 50),
                  dashLine(),
                  SizedBox(height: 4),

                  //userInfo
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 40,
                            color: !darkMode
                                ? Color.fromRGBO(130, 0, 219, 1.0)
                                : Color.fromRGBO(255, 121, 172, 1),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hồ sơ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: !darkMode
                                      ? Color.fromRGBO(130, 0, 219, 1.0)
                                      : Color.fromRGBO(255, 121, 172, 1),
                                ),
                              ),
                              Text(
                                'Chỉnh sửa hồ sơ của bạn',
                                style: TextStyle(
                                  color: darkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  //userLibrary
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.library_books,
                            size: 40,
                            color: !darkMode
                                ? Color.fromRGBO(130, 0, 219, 1.0)
                                : Color.fromRGBO(255, 121, 172, 1),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thư viện',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: !darkMode
                                      ? Color.fromRGBO(130, 0, 219, 1.0)
                                      : Color.fromRGBO(255, 121, 172, 1),
                                ),
                              ),
                              Text(
                                'Xem lại những bộ truyện của bạn',
                                style: TextStyle(
                                  color: darkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  //userSetting
                  InkWell(
                    onTap: () async {
                      var doc = await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(uid)
                          .get();
                      String theme = doc.data()!["theme"];
                      updateTheme(theme);
                      setState(() {
                        if (theme == "light") {
                          isDark = true;
                        } else {
                          isDark = false;
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.settings,
                            size: 40,
                            color: !darkMode
                                ? Color.fromRGBO(130, 0, 219, 1.0)
                                : Color.fromRGBO(255, 121, 172, 1),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cài đặt',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: !darkMode
                                      ? Color.fromRGBO(130, 0, 219, 1.0)
                                      : Color.fromRGBO(255, 121, 172, 1),
                                ),
                              ),
                              Text(
                                'Chỉnh nền sáng tối tại đây',
                                style: TextStyle(
                                  color: darkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),

                  dashLine(),
                  SizedBox(height: 4),

                  InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.logout,
                            size: 40,
                            color: Color.fromRGBO(251, 44, 54, 1.0),
                          ),
                          SizedBox(width: 20),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromRGBO(251, 44, 54, 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateTheme(String theme) async {
    var doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get();
    String theme = doc.data()!["theme"];

    if (theme == "light") {
      FirebaseFirestore.instance.collection("Users").doc(uid).update({
        "theme": "dark",
      });
    } else {
      FirebaseFirestore.instance.collection("Users").doc(uid).update({
        "theme": "light",
      });
    }
  }
}

class dashLine extends StatelessWidget {
  const dashLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: Colors.grey,
      margin: EdgeInsets.symmetric(horizontal: 30),
    );
  }
}
