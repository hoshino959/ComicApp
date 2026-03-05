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

class UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              margin: EdgeInsets.all(30),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 60),
                  Container(height: 2, color: Colors.grey),
                  SizedBox(height: 20),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 40,
                          color: !isDark
                              ? Color.fromRGBO(
                                  130,
                                  0,
                                  219,
                                  1.0,
                                )
                              : Color.fromRGBO(
                                  255,
                                  121,
                                  172,
                                  1,
                                ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hồ sơ',
                              style: TextStyle(
                                fontSize: 18,
                                color: !isDark
                                    ? Color.fromRGBO(
                                        130,
                                        0,
                                        219,
                                        1.0,
                                      )
                                    : Color.fromRGBO(
                                        255,
                                        121,
                                        172,
                                        1,
                                      ),
                              ),
                            ),
                            Text(
                              'Chỉnh sửa hồ sơ của bạn',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.library_books,
                          size: 40,
                          color: !isDark
                              ? Color.fromRGBO(
                                  130,
                                  0,
                                  219,
                                  1.0,
                                )
                              : Color.fromRGBO(
                                  255,
                                  121,
                                  172,
                                  1,
                                ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thư viện',
                              style: TextStyle(
                                fontSize: 18,
                                color: !isDark
                                    ? Color.fromRGBO(
                                        130,
                                        0,
                                        219,
                                        1.0,
                                      )
                                    : Color.fromRGBO(
                                        255,
                                        121,
                                        172,
                                        1,
                                      ),
                              ),
                            ),
                            Text(
                              'Xem lại những bộ truyện của bạn',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 40,
                          color: !isDark
                              ? Color.fromRGBO(
                                  130,
                                  0,
                                  219,
                                  1.0,
                                )
                              : Color.fromRGBO(
                                  255,
                                  121,
                                  172,
                                  1,
                                ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cài đặt',
                              style: TextStyle(
                                fontSize: 18,
                                color: !isDark
                                    ? Color.fromRGBO(
                                        130,
                                        0,
                                        219,
                                        1.0,
                                      )
                                    : Color.fromRGBO(
                                        255,
                                        121,
                                        172,
                                        1,
                                      ),
                              ),
                            ),
                            Text(
                              'Chỉnh nền sáng tối tại đây',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(height: 2, color: Colors.grey),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 40,
                          color: Color.fromRGBO(
                            251,
                            44,
                            54,
                            1.0,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromRGBO(
                              251,
                              44,
                              54,
                              1.0,
                            ),
                          ),
                        ),
                      ],
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
}
