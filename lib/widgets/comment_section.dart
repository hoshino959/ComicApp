import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/models/comment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final String comicId;

  const CommentSection({super.key, required this.comicId});

  @override
  State<StatefulWidget> createState() {
    return _CommentSectionState();
  }
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController controller = TextEditingController();
  int page = 0;
  final int limit = 10;
  String nameFS = "";
  String imgUrl = "";
  bool isLoading = true;

  String formatTime(DateTime time) {
    return "${time.hour}:${time.minute} - ${time.day}/${time.month}/${time.year}";
  }

  Future<void> getUserData() async {
    var doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      nameFS = doc.data()!['name'];
      imgUrl = doc.data()!['avatar'];
      isLoading = false;
    });
  }

  @override
  initState() {
    super.initState();
    getUserData();
  }

  Future<void> addComment() async {
    setState(() {
      isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (controller.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('Comments')
        .doc(widget.comicId)
        .collection('comments')
        .doc()
        .set({
          'userId': user.uid,
          'content': controller.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
    controller.clear();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (imgUrl.isEmpty)
                        ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (imgUrl.isNotEmpty)
                        ClipOval(
                          child: Image.network(
                            imgUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(width: 12),
                      Expanded(child: Text(nameFS)),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    maxLength: 2000,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Nhập bình luận...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: addComment,
                      child: Text("Đăng"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Comments')
                  .doc(widget.comicId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .limit((page + 1) * limit)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<CommentModel> comments = snapshot.data!.docs.map((doc) {
                  return CommentModel.fromFirestore(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  );
                }).toList();

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final cmt = comments[index];

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(cmt.userId)
                              .get(),

                          builder: (context, userSnap) {
                            String username = "User";
                            String? avatar;

                            if (userSnap.hasData && userSnap.data!.exists) {
                              final data =
                                  userSnap.data!.data() as Map<String, dynamic>;
                              username = data['name'] ?? "User";
                              avatar = data['avatar'];
                            }

                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: avatar != null
                                        ? NetworkImage(avatar)
                                        : null,
                                    child: avatar == null
                                        ? Icon(Icons.person)
                                        : null,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          formatTime(cmt.createdAt),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(height: 5),
                                        Text(cmt.content),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (
                          int i = 0;
                          i < (comments.length / limit).ceil();
                          i++
                        )
                          TextButton(
                            onPressed: () {
                              setState(() {
                                page = i;
                              });
                            },
                            child: Text("${i + 1}"),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: (BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
              )),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
