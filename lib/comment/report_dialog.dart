import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/comment/show_info_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';

class ReportDialog extends StatefulWidget {
  final String userId;
  final BuildContext parentContext;

  const ReportDialog({
    super.key,
    required this.userId,
    required this.parentContext,
  });

  @override
  State<StatefulWidget> createState() {
    return _ReportDialogState();
  }
}

class _ReportDialogState extends State<ReportDialog> {
  String nameFS = "";
  String imgUrl = "";
  String email = "";

  @override
  initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userId)
        .get();

    setState(() {
      nameFS = doc.data()?['name'] ?? "";
      imgUrl = doc.data()?['avatar'] ?? "";
      email = doc.data()?['email'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (nameFS.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Tố cáo $nameFS',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  imgUrl,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                nameFS,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: OkLab(0.63, 0.15, -0.22).toColor(),
                                ),
                              ),
                              Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                email,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          width: 20,
                          thickness: 1,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: TextField(
                            maxLength: 100,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Nhập lý do tố cáo...",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: widget.parentContext,
                        builder: (context) => ShowInfoUser(uid: widget.userId),
                      );
                    },
                    child: Text('Hủy'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
