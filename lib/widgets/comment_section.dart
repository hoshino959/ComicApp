import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

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
  String? replyingCommentId;
  String? replyingUserId;
  String? replyingUserName;
  Map<String, bool> showReplies = {};
  String nameFS = "";
  String imgUrl = "";
  bool isLoading = true;
  bool isLike = false;

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

    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập nội dung')));
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (replyingCommentId != null) {
      await FirebaseFirestore.instance
          .collection('Comments')
          .doc(widget.comicId)
          .collection('comments')
          .doc(replyingCommentId)
          .collection('replies')
          .add({
            'userId': user.uid,
            'userName': nameFS,
            'avatar': imgUrl,
            'content': controller.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'like': 0,
            'replyToUserId': replyingUserId,
            'replyToUserName': replyingUserName,
          });
      replyingCommentId = null;
      replyingUserName = null;
      replyingUserId = null;
    } else {
      await FirebaseFirestore.instance
          .collection('Comments')
          .doc(widget.comicId)
          .collection('comments')
          .add({
            'userId': user.uid,
            'content': controller.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'userName': nameFS,
            'avatar': imgUrl,
            'like': 0,
          });
    }
    controller.clear();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? OkLab(0.28, -0.01, -0.03).toColor().withValues(alpha: 0.5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
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
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nameFS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? OkLab(0.83, 0.07, -0.1).toColor()
                                : OkLab(0.63, 0.15, -0.22).toColor(),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: addComment,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? OkLab(0.63, 0.24, 0).toColor()
                              : OkLab(0.75, 0.17, -0.01).toColor(),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Đăng",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
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
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi tải bình luận',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Chưa có bình luận tại truyện này',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final content = data['content'] ?? '';
                    final Timestamp? timestamp = data['createdAt'];
                    final DateTime createdAt = timestamp != null
                        ? timestamp.toDate()
                        : DateTime.now();
                    final avatar = data['avatar'] ?? '';
                    final userName = data['userName'] ?? '';

                    final like = data['like'] ?? 0;
                    final commentId = docs[index].id;
                    final showReply = showReplies[commentId] ?? false;

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: avatar == null
                                    ? Icon(Icons.person)
                                    : Image.network(
                                        avatar,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? OkLab(0.83, 0.07, -0.1).toColor()
                                            : OkLab(
                                                0.63,
                                                0.15,
                                                -0.22,
                                              ).toColor(),
                                      ),
                                    ),
                                    Text(
                                      formatTime(createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? OkLab(0.71, 0, -0.02).toColor()
                                            : OkLab(0.55, 0, -0.03).toColor(),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? OkLab(
                                                0.28,
                                                -0.01,
                                                -0.03,
                                              ).toColor()
                                            : OkLab(0.98, 0, 0).toColor(),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        content,
                                        style: TextStyle(
                                          color: isDark
                                              ? OkLab(0.71, 0, -0.02).toColor()
                                              : OkLab(
                                                  0.45,
                                                  -0.01,
                                                  -0.03,
                                                ).toColor(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      children: [
                                        if (like > 0)
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: OkLab(
                                                    0.93,
                                                    -0.01,
                                                    -0.03,
                                                  ).toColor(),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text('👍'),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "$like",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        SizedBox(width: 10),
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Comments')
                                              .doc(widget.comicId)
                                              .collection('comments')
                                              .doc(commentId)
                                              .collection('likes')
                                              .doc(
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid,
                                              )
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            final isLike =
                                                snapshot.data?.exists ?? false;
                                            return GestureDetector(
                                              onTap: () async {
                                                final userId = FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid;
                                                final likeRef =
                                                    FirebaseFirestore.instance
                                                        .collection('Comments')
                                                        .doc(widget.comicId)
                                                        .collection('comments')
                                                        .doc(commentId)
                                                        .collection('likes')
                                                        .doc(userId);
                                                if (isLike) {
                                                  await Future.wait([
                                                    likeRef.delete(),
                                                    FirebaseFirestore.instance
                                                        .collection('Comments')
                                                        .doc(widget.comicId)
                                                        .collection('comments')
                                                        .doc(commentId)
                                                        .update({
                                                          'like':
                                                              FieldValue.increment(
                                                                -1,
                                                              ),
                                                        }),
                                                  ]);
                                                } else {
                                                  await Future.wait([
                                                    likeRef.set({
                                                      'userId': userId,
                                                    }),
                                                    FirebaseFirestore.instance
                                                        .collection('Comments')
                                                        .doc(widget.comicId)
                                                        .collection('comments')
                                                        .doc(commentId)
                                                        .update({
                                                          'like':
                                                              FieldValue.increment(
                                                                1,
                                                              ),
                                                        }),
                                                  ]);
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  !isLike
                                                      ? Icon(
                                                          Icons
                                                              .thumb_up_off_alt_outlined,
                                                          size: 20,
                                                          color: OkLab(
                                                            0.55,
                                                            0,
                                                            -0.03,
                                                          ).toColor(),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        )
                                                      : Text(
                                                          '👍',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    'Thích',
                                                    style: TextStyle(
                                                      color: !isLike
                                                          ? OkLab(
                                                              0.55,
                                                              0,
                                                              -0.03,
                                                            ).toColor()
                                                          : OkLab(
                                                              0.62,
                                                              -0.04,
                                                              -0.21,
                                                            ).toColor(),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.chat_bubble_outline_sharp,
                                                size: 20,
                                                color: OkLab(
                                                  0.55,
                                                  0,
                                                  -0.03,
                                                ).toColor(),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Trả lời',
                                                style: TextStyle(
                                                  color: OkLab(
                                                    0.55,
                                                    0,
                                                    -0.03,
                                                  ).toColor(),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Divider(
                            thickness: 1,
                            color: isDark
                                ? OkLab(0.28, -0.01, -0.03).toColor()
                                : Colors.grey,
                          ),
                        ],
                      ),
                    );
                  },
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
