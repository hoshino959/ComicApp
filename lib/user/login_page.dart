import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/screens/main_screen.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool obscurePassword = true;
  bool isChecked = false;
  bool isForgot = false;
  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController rePassController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    rePassController.dispose();
    super.dispose();
  }

  //Loading
  Widget loadingCircle(BuildContext context) {
    return CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    final gradient = isDark
        ? AppColorsDark.gradientBackground
        : AppColorsLight.gradientBackground;

    return Stack(
      children: [
        SafeArea(
          child: Stack(
            children: [
              Scaffold(
                extendBodyBehindAppBar: true,
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
                body: Container(
                  decoration: BoxDecoration(gradient: gradient),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          //Logo và tên app
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Comic Garden',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontFamily: 'Brush_Script_MT_Italic',
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Color.fromRGBO(246, 51, 154, 1.0)
                                      : Color.fromRGBO(230, 0, 118, 1.0),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),

                          //Nút bấm đăng nhập đăng ký
                          if (!isForgot)
                            Column(
                              children: [
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black
                                        : Colors.pink.shade100,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isLogin = true;
                                              emailController.clear();
                                              passController.clear();
                                              rePassController.clear();
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                              4,
                                              4,
                                              0,
                                              4,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isLogin
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Đăng nhập',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isLogin
                                                      ? Color.fromRGBO(
                                                          130,
                                                          0,
                                                          219,
                                                          1.0,
                                                        )
                                                      : isDark
                                                      ? Colors.grey
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isLogin = false;
                                              emailController.clear();
                                              passController.clear();
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                              0,
                                              4,
                                              4,
                                              4,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: !isLogin
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Đăng ký',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: !isLogin
                                                      ? Color.fromRGBO(
                                                          130,
                                                          0,
                                                          219,
                                                          1.0,
                                                        )
                                                      : isDark
                                                      ? Colors.grey
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 30),
                              ],
                            ),

                          //Form đăng nhập
                          Container(
                            width: 350,
                            padding: EdgeInsets.all(20),
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
                            child: Column(
                              children: [
                                isForgot
                                    ? Column(
                                        children: [
                                          Text(
                                            'Quên mật khẩu',
                                            style: TextStyle(
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
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Nhập email của bạn chúng tôi sẽ gửi link để khôi phục mật khẩu cho bạn.',
                                            style: TextStyle(
                                              color: !isDark
                                                  ? Colors.black45
                                                  : Colors.grey,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : isLogin
                                    ? Column(
                                        children: [
                                          Text(
                                            'Chào mừng trở lại',
                                            style: TextStyle(
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
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Đăng nhập vào tài khoản của bạn để tiếp tục đọc truyện yêu thích',
                                            style: TextStyle(
                                              color: !isDark
                                                  ? Colors.black45
                                                  : Colors.grey,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Text(
                                            'Tạo tài khoản',
                                            style: TextStyle(
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
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Tham gia cộng đồng yêu thích truyện tranh của chúng tôi',
                                            style: TextStyle(
                                              color: !isDark
                                                  ? Colors.black45
                                                  : Colors.grey,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: !isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                TextField(
                                  controller: emailController,
                                  style: TextStyle(
                                    color: !isDark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'abcxyz@gmail.com',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: Icon(Icons.email),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          246,
                                          51,
                                          154,
                                          1.0,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(
                                          246,
                                          51,
                                          154,
                                          1.0,
                                        ),
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                isForgot
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Mật khẩu',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: !isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              isLogin
                                                  ? Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            isForgot =
                                                                !isForgot;
                                                            emailController
                                                                .clear();
                                                          });
                                                        },
                                                        child: Text(
                                                          'Quên mật khẩu',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Color.fromRGBO(
                                                                  246,
                                                                  51,
                                                                  154,
                                                                  1.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          TextField(
                                            controller: passController,
                                            style: TextStyle(
                                              color: !isDark
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            obscureText: obscurePassword,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                    246,
                                                    51,
                                                    154,
                                                    1.0,
                                                  ),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                    246,
                                                    51,
                                                    154,
                                                    1.0,
                                                  ),
                                                  width: 3.0,
                                                ),
                                              ),

                                              hintText: '••••••••',
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                              ),
                                              prefixIcon: Icon(Icons.lock),

                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    obscurePassword =
                                                        !obscurePassword;
                                                  });
                                                },
                                                icon: Icon(
                                                  obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                        ],
                                      ),
                                //Form Đăng ký
                                isLogin
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Xác nhận mật khẩu',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: !isDark
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          TextField(
                                            style: TextStyle(
                                              color: !isDark
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            controller: rePassController,
                                            obscureText: obscurePassword,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                    246,
                                                    51,
                                                    154,
                                                    1.0,
                                                  ),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                    246,
                                                    51,
                                                    154,
                                                    1.0,
                                                  ),
                                                  width: 3.0,
                                                ),
                                              ),
                                              hintText: '••••••••',
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                              ),
                                              prefixIcon: Icon(Icons.lock),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: isChecked,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isChecked = value!;
                                                  });
                                                },
                                                shape: CircleBorder(),
                                                side: BorderSide(
                                                  color: Color.fromRGBO(
                                                    246,
                                                    51,
                                                    154,
                                                    1.0,
                                                  ),
                                                  width: 2,
                                                ),

                                                fillColor:
                                                    WidgetStateProperty.resolveWith<
                                                      Color
                                                    >((states) {
                                                      if (states.contains(
                                                        WidgetState.selected,
                                                      )) {
                                                        return Color.fromRGBO(
                                                          246,
                                                          51,
                                                          154,
                                                          1.0,
                                                        );
                                                      }
                                                      return Colors.white;
                                                    }),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Tôi đồng ý với điều khoản dịch vụ',
                                                  style: TextStyle(
                                                    color: !isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isForgot
                                        ? () async {
                                            if (!emailController.text
                                                .trim()
                                                .endsWith('@gmail.com')) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Email không hợp lệ, Email phải có đuôi gmail',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              try {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await FirebaseAuth.instance
                                                    .sendPasswordResetEmail(
                                                      email: emailController
                                                          .text
                                                          .trim(),
                                                    );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Đã gửi email khôi phục mật khẩu',
                                                    ),
                                                  ),
                                                );
                                                setState(() {
                                                  isForgot = false;
                                                  isLogin = true;
                                                  isLoading = false;
                                                  emailController.clear();
                                                });
                                              } on FirebaseAuthException catch (
                                                e
                                              ) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.message ??
                                                          'Lỗi gửi email',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        : isLogin
                                        ? () async {
                                            if (emailController.text
                                                    .trim()
                                                    .isEmpty ||
                                                passController.text
                                                    .trim()
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Vui lòng điền đầy đủ thông tin để đăng nhập',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            try {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              await FirebaseAuth.instance
                                                  .signInWithEmailAndPassword(
                                                    email: emailController.text
                                                        .trim(),
                                                    password: passController
                                                        .text
                                                        .trim(),
                                                  );

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MainScreen(),
                                                ),
                                                (Route<dynamic> route) => false,
                                              );
                                              setState(() {
                                                isLoading = false;
                                              });
                                            } on FirebaseAuthException catch (
                                              e
                                            ) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e.message ??
                                                        "Đăng nhập thất bại",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        : (isChecked
                                              ? () async {
                                                  if (!emailController.text
                                                      .trim()
                                                      .endsWith('@gmail.com')) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Email không hợp lệ, Email phải có đuôi gmail',
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  if (passController.text !=
                                                      rePassController.text) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Mật khẩu không trùng với Xác nhận mật khẩu',
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  if (emailController.text
                                                          .trim()
                                                          .isEmpty ||
                                                      passController
                                                          .text
                                                          .isEmpty ||
                                                      rePassController
                                                          .text
                                                          .isEmpty) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Vui lòng điền đầy đủ thông tin để đăng ký',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  } else {
                                                    try {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      await FirebaseAuth
                                                          .instance
                                                          .createUserWithEmailAndPassword(
                                                            email:
                                                                emailController
                                                                    .text
                                                                    .trim(),
                                                            password:
                                                                passController
                                                                    .text
                                                                    .trim(),
                                                          );
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("Users")
                                                          .doc(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                          )
                                                          .set({
                                                            'email':
                                                                emailController
                                                                    .text
                                                                    .trim(),
                                                            'password':
                                                                passController
                                                                    .text,
                                                            'uid': FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            'name':
                                                                'Người dùng mới',
                                                            'theme': isDark
                                                                ? 'dark'
                                                                : 'light',
                                                            'gender': '',
                                                            'avatar':
                                                                'https://res.cloudinary.com/dxbtuad7u/image/upload/v1774780859/logo_eehlrv.png',
                                                            'createdAt':
                                                                FieldValue.serverTimestamp(),
                                                            'description': '',
                                                          });
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Đăng ký thành công",
                                                          ),
                                                        ),
                                                      );

                                                      setState(() {
                                                        isLogin = true;
                                                        isLoading = false;
                                                      });
                                                    } on FirebaseAuthException catch (
                                                      e
                                                    ) {
                                                      String message;
                                                      switch (e.code) {
                                                        case 'email-already-in-use':
                                                          message =
                                                              'Email đã được sử dụng';
                                                          break;
                                                        case 'invalid-email':
                                                          message =
                                                              'Email không hợp lệ';
                                                          break;
                                                        case 'weak-password':
                                                          message =
                                                              'Mật khẩu quá yếu';
                                                          break;
                                                        default:
                                                          message =
                                                              'Đã có lỗi xảy ra, vui lòng thử lại';
                                                      }
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            message,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              : null),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromRGBO(
                                        246,
                                        51,
                                        154,
                                        1.0,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      isForgot
                                          ? 'Gửi liên kết khôi phục mật khẩu'
                                          : isLogin
                                          ? 'Đăng nhập'
                                          : 'Đăng ký',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isForgot)
                                  Column(
                                    children: [
                                      SizedBox(height: 10),
                                      GestureDetector(
                                        child: Text(
                                          'Quay lại đăng nhập',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                              246,
                                              51,
                                              154,
                                              1.0,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            isForgot = false;
                                            emailController.clear();
                                          });
                                        },
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
        ),
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class logoWidget extends StatelessWidget {
  const logoWidget({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        Text(
          '  Comic Garden',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Color.fromRGBO(246, 51, 154, 1.0)
                : Color.fromRGBO(230, 0, 118, 1.0),
          ),
        ),
      ],
    );
  }
}
