import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/screens/main_screen.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  // bool isLoading;
  bool isEditing = false;
  String gender = "";
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hồ sơ của tôi',
                                  style: TextStyle(
                                    color: !isDark
                                        ? Color.fromRGBO(130, 0, 219, 1.0)
                                        : Color.fromRGBO(255, 121, 172, 1),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Quản lý cài đặt tài khoản và tùy chọn của bạn',
                                  style: TextStyle(
                                    color: !isDark
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: !isDark ? Colors.white : Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: !isDark ? Colors.black12 : Colors.grey,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'ZhazF1',
                              style: TextStyle(
                                color: !isDark
                                    ? Color(0xff7B1FA2)
                                    : Color(0xffba68c8),
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              height: 2,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 121, 172, 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.white),
                                  SizedBox(width: 15),
                                  Text(
                                    'Thông tin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => MainScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Color.fromRGBO(251, 44, 54, 1.0),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      'Đăng xuất',
                                      style: TextStyle(
                                        color: Color.fromRGBO(251, 44, 54, 1.0),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),

                      //changeInfoUser
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: !isDark ? Colors.white : Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: !isDark ? Colors.black12 : Colors.grey,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Thông tin hồ sơ',
                                        style: TextStyle(
                                          color: !isDark
                                              ? Color(0xff7B1FA2)
                                              : Color(0xffba68c8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        'Cập nhật thông tin',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                !isEditing
                                    ? ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'Chỉnh sửa',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isEditing = false;
                                              });
                                            },
                                            child: Text(
                                              'Hủy',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isDark
                                                  ? Colors.pink
                                                  : Colors.pinkAccent,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isEditing = false;
                                              });
                                            },
                                            child: Text(
                                              'Lưu',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  'Họ và tên',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: isEditing
                                      ? TextField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 10,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          'ZhazF1',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: 'Nam',
                                      groupValue: gender,
                                      activeColor: Colors.pink,
                                      onChanged: isEditing
                                          ? (value) {
                                              setState(() {
                                                gender = value!;
                                              });
                                            }
                                          : null,
                                    ),
                                    Text('Nam'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: 'Nữ',
                                      groupValue: gender,
                                      activeColor: Colors.pink,
                                      onChanged: isEditing
                                          ? (value) {
                                              setState(() {
                                                gender = value!;
                                              });
                                            }
                                          : null,
                                    ),
                                    Text('Nữ'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: 'Khác',
                                      groupValue: gender,
                                      activeColor: Colors.pink,
                                      onChanged: isEditing
                                          ? (value) {
                                              setState(() {
                                                gender = value!;
                                              });
                                            }
                                          : null,
                                    ),
                                    Text('Khác'),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'thepig6704@gmail.com',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
