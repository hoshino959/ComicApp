import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
          ClipRRect(
            child: Image.network(imgUrl),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nameFS,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: OkLab(0.63, 0.15, -0.22).toColor(),
            ),
          ),
          Text(formatDate(createdAt), style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
