import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:comic_app/screens/main_screen.dart';
import 'package:comic_app/theme/app_dark_colors.dart';
import 'package:comic_app/theme/app_light_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:okcolor/models/oklab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  File? avatarImage;
  final ImagePicker picker = ImagePicker();

  final cloudinary = CloudinaryPublic("dxbtuad7u", "Avatar_Upload");

  bool isLoading = false;
  bool isEditing = false;
  String nameFS = "";
  String gender = "";
  String emailFS = "";
  String imgUrl = "";
  String bioFS = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });
    var doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      nameFS = doc.data()!["name"];
      gender = doc.data()!["gender"];
      emailFS = doc.data()!["email"];
      nameController.text = nameFS;
      imgUrl = doc.data()!["avatar"];
      bioFS = doc.data()!['description'];
      bioController.text = bioFS;
      isLoading = false;
    });
  }

  Future<void> pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    File image = File(pickedFile.path);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Text(
                  'Thay đổi avatar',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  image,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                          ? OkLab(0.75, 0.17, -0.0).toColor()
                          : OkLab(0.75, 0.17, -0.01).toColor(),
                      side: BorderSide(color: OkLab(0.88, 0.04, 0).toColor()),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      String imageUrl = await uploadToCloudinary(image);

                      await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({"avatar": imageUrl});

                      setState(() {
                        avatarImage = image;
                        getUserData();
                      });
                    },
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: OkLab(0.88, 0.04, 0).toColor()),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future uploadToCloudinary(File imageFile) async {
    try {
      setState(() {
        isLoading = true;
      });
      String uid = FirebaseAuth.instance.currentUser!.uid;
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          identifier: uid,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

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
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hồ sơ của tôi',
                                style: TextStyle(
                                  color: isDark
                                      ? OkLab(0.83, 0.07, -0.1).toColor()
                                      : OkLab(0.5, 0.14, -0.22).toColor(),
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
                                  color: !isDark ? Colors.black : Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColorsDark.background3
                              : AppColorsLight.background2,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(blurRadius: 10, color: Colors.black26),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                if (imgUrl.isEmpty)
                                  ClipOval(
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                if (imgUrl.isNotEmpty)
                                  ClipOval(
                                    child: Image.network(
                                      imgUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      pickAndUploadImage();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Color(0xff7d60fb),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              nameFS,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? OkLab(0.83, 0.07, -0.1).toColor()
                                    : OkLab(0.5, 0.14, -0.22).toColor(),
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              height: 2,
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? OkLab(0.41, 0.15, 0.01).toColor()
                                    : OkLab(0.72, 0.2, -0.04).toColor(),
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
                                if (!context.mounted) return;
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
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? OkLab(0.64, 0.21, 0.1).toColor()
                                          : OkLab(0.7, 0.18, 0.07).toColor(),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      'Đăng xuất',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.light
                                            ? OkLab(0.64, 0.21, 0.1).toColor()
                                            : OkLab(0.7, 0.18, 0.07).toColor(),
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
                          color: isDark
                              ? AppColorsDark.background3
                              : AppColorsLight.background2,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(blurRadius: 10, color: Colors.black26),
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
                                          color: isDark
                                              ? OkLab(
                                                  0.83,
                                                  0.07,
                                                  -0.1,
                                                ).toColor()
                                              : OkLab(
                                                  0.5,
                                                  0.14,
                                                  -0.22,
                                                ).toColor(),
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
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark
                                              ? OkLab(0.63, 0.24, 0).toColor()
                                              : OkLab(
                                                  0.75,
                                                  0.17,
                                                  -0.01,
                                                ).toColor(),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isDark
                                                  ? Colors.transparent
                                                  : Colors.white,
                                            ),
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
                                                  ? OkLab(
                                                      0.63,
                                                      0.24,
                                                      0,
                                                    ).toColor()
                                                  : OkLab(
                                                      0.75,
                                                      0.17,
                                                      -0.01,
                                                    ).toColor(),
                                            ),
                                            onPressed: () async {
                                              if (nameController.text.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Tên không được để trống',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                await FirebaseFirestore.instance
                                                    .collection("Users")
                                                    .doc(
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                    )
                                                    .update({
                                                      "name":
                                                          nameController.text,
                                                      "gender": gender,
                                                      'description':
                                                          bioController.text,
                                                    });
                                                setState(() {
                                                  getUserData();
                                                  isEditing = false;
                                                });
                                              }
                                            },
                                            child: Text(
                                              'Lưu',
                                              style: TextStyle(
                                                color: Colors.white,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            !isEditing
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.account_circle,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          nameFS,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        maxLength: 50,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.account_circle,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                                  emailFS,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giới thiệu về bản thân',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            !isEditing
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                          bioFS,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      TextField(
                                        controller: bioController,
                                        maxLength: 100,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.info),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
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
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
