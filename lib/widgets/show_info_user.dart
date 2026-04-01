import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:okcolor/models/oklab.dart';

class ShowInfoUser extends StatefulWidget {
  final String uid;

  const ShowInfoUser({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() {
    return _ShowInfoUserState();
  }
}

class _ShowInfoUserState extends State<ShowInfoUser> {
  String nameFS = "";
  String imgUrl = "";
  DateTime? createdAt;
  String gender = "";
  String bio = "";
  String email = "";

  @override
  initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.uid)
        .get();

    setState(() {
      nameFS = doc.data()?['name'] ?? "";
      imgUrl = doc.data()?['avatar'] ?? "";
      createdAt = (doc.data()?['createdAt'] as Timestamp?)?.toDate();
      gender = doc.data()?['gender'];
      bio = doc.data()?['description'];
      email = doc.data()?['email'];
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imgUrl.isNotEmpty)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                  ),
                  child: Image.network(imgUrl),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    nameFS,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: OkLab(0.63, 0.15, -0.22).toColor(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        'Ngày tạo tài khoản: ${formatDate(createdAt)}',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Giới tính: $gender',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        maxLines: 4,
                        'Mô tả bản thân: $bio',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Email: $email',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('Tố cáo người dùng')],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
