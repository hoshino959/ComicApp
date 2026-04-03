import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/comment/show_info_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:provider/provider.dart';

class CommentSection extends StatefulWidget {
  final String comicId;
  final String comicTitle;
  final String coverUrl;

  const CommentSection({
    super.key,
    required this.comicId,
    required this.comicTitle,
    required this.coverUrl,
  });

  @override
  State<StatefulWidget> createState() {
    return _CommentSectionState();
  }
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController controller = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};

  String? replyingCommentId;
  String? replyingUserId;
  String? replyingUserName;

  Map<String, bool> showReplyInput = {};
  Map<String, bool> showReplies = {};

  String nameFS = '';
  String imgUrl = "";
  bool isLoading = true;
  bool isLike = false;

  CollectionReference get _commentRef => FirebaseFirestore.instance
      .collection('Comments')
      .doc(widget.comicId)
      .collection('comments');

  @override
  initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    controller.dispose();
    for (var c in _replyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> getUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      nameFS = doc.data()!['name'];
      imgUrl = doc.data()!['avatar'];
      isLoading = false;
    });
  }

  Future<void> addComment({String? text}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final content = text ?? controller.text.trim();
    if (content.isEmpty) return;

    if (!mounted) return;
    setState(() => isLoading = true);

    if (replyingCommentId != null) {
      final replyDoc = await _commentRef
          .doc(replyingCommentId)
          .collection('replies')
          .add({
            'userId': user.uid,
            'userName': nameFS,
            'avatar': imgUrl,
            'content': "@$replyingUserName $content",
            'createdAt': FieldValue.serverTimestamp(),
            'like': 0,
            'replyToUserId': replyingUserId,
            'replyToUserName': replyingUserName,
          });
      if (replyingUserId != null) {
        await FirebaseFirestore.instance
            .collection('Notification')
            .doc(replyingUserId)
            .collection('comments_notification')
            .doc(replyDoc.id)
            .set({
              'type': 'reply',
              'comicId': widget.comicId,
              'comicTitle': widget.comicTitle,
              'coverUrl': widget.coverUrl,
              'commentId': replyingCommentId,
              'replyId': replyDoc.id,
              'fromUserId': user.uid,
              'fromUserName': nameFS,
              'content': content,
              'createdAt': FieldValue.serverTimestamp(),
              'status': false,
            });
      }
    } else {
      await _commentRef.add({
        'userId': user.uid,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'userName': nameFS,
        'avatar': imgUrl,
        'like': 0,
      });
    }

    await FirebaseFirestore.instance
        .collection('Comments')
        .doc(widget.comicId)
        .set({
          'totalComments': FieldValue.increment(1),
        }, SetOptions(merge: true));

    controller.clear();
    replyingCommentId = null;
    replyingUserId = null;
    replyingUserName = null;

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Stack(
      children: [
        Column(
          children: [
            CommentInputBox(
              isDark: isDark,
              avatar: imgUrl,
              userName: nameFS,
              controller: controller,
              onSubmit: addComment,
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _commentRef
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

                    final uid = data['userId'];

                    final like = data['like'] ?? 0;
                    final commentId = docs[index].id;

                    return StatefulBuilder(
                      builder: (context, localSetState) {
                        final isShowReplyInput =
                            showReplyInput[commentId] ?? false;
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    child: BuildAvatarComment(url: avatar),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            ShowInfoUser(uid: uid),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        UserNameComment(
                                          nameFS: userName,
                                          isDark: isDark,
                                        ),
                                        CreatedAtComment(
                                          createdAt: createdAt,
                                          isDark: isDark,
                                        ),
                                        SizedBox(height: 5),
                                        ContentComment(
                                          isDark: isDark,
                                          content: content,
                                        ),
                                        CommentActionBar(
                                          likeCount: like,
                                          targetRef: _commentRef.doc(commentId),
                                          onReplyTap: () {
                                            localSetState(() {
                                              replyingCommentId = commentId;
                                              replyingUserId = data['userId'];
                                              replyingUserName =
                                                  data['userName'];
                                              showReplyInput[commentId] =
                                                  !(showReplyInput[commentId] ??
                                                      false);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isShowReplyInput)
                                Padding(
                                  padding: EdgeInsets.only(top: 10, left: 50),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? OkLab(
                                              0.28,
                                              -0.01,
                                              -0.03,
                                            ).toColor().withValues(alpha: 0.5)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Trả lời ',
                                              style: TextStyle(
                                                color: OkLab(
                                                  0.45,
                                                  -0.01,
                                                  -0.03,
                                                ).toColor(),
                                              ),
                                            ),
                                            Text(
                                              '@$replyingUserName',
                                              style: TextStyle(
                                                color: OkLab(
                                                  0.44,
                                                  0.12,
                                                  -0.18,
                                                ).toColor(),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            BuildAvatarComment(url: imgUrl),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                nameFS,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? OkLab(
                                                          0.83,
                                                          0.07,
                                                          -0.1,
                                                        ).toColor()
                                                      : OkLab(
                                                          0.63,
                                                          0.15,
                                                          -0.22,
                                                        ).toColor(),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        TextField(
                                          controller: _replyControllers
                                              .putIfAbsent(
                                                commentId,
                                                () => TextEditingController(),
                                              ),
                                          maxLength: 2000,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText: "Nhập bình luận",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                localSetState(() {
                                                  showReplyInput[commentId] =
                                                      false;
                                                  _replyControllers[commentId]
                                                      ?.clear();
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? OkLab(
                                                          0.97,
                                                          0,
                                                          0,
                                                        ).toColor().withValues(
                                                          alpha: 0.3,
                                                        )
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                    width: 2,
                                                    color: isDark
                                                        ? OkLab(0.97, 0, 0)
                                                              .toColor()
                                                              .withValues(
                                                                alpha: 0.3,
                                                              )
                                                        : OkLab(
                                                            0.88,
                                                            0.04,
                                                            0,
                                                          ).toColor(),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Hủy",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: OkLab(
                                                      0.55,
                                                      0,
                                                      -0.03,
                                                    ).toColor(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                final replyController =
                                                    _replyControllers[commentId];
                                                if (replyController != null &&
                                                    replyController.text
                                                        .trim()
                                                        .isNotEmpty) {
                                                  addComment(
                                                    text: replyController.text
                                                        .trim(),
                                                  );
                                                  replyController.clear();
                                                  localSetState(() {
                                                    showReplyInput[commentId] =
                                                        false;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isDark
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
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Đăng",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (isShowReplyInput) SizedBox(height: 20),
                              StreamBuilder<QuerySnapshot>(
                                stream: _commentRef
                                    .doc(commentId)
                                    .collection('replies')
                                    .orderBy('createdAt', descending: false)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return SizedBox();

                                  if (snapshot.data!.docs.isEmpty) {
                                    return SizedBox();
                                  }
                                  final isShow =
                                      showReplies[commentId] ?? false;
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          localSetState(() {
                                            showReplies[commentId] = !isShow;
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 50),
                                          child: Text(
                                            isShow
                                                ? "Ẩn ${snapshot.data!.docs.length} câu trả lời"
                                                : "Hiện ${snapshot.data!.docs.length} câu trả lời",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isShow)
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            final replyData =
                                                snapshot.data!.docs[index]
                                                        .data()
                                                    as Map<String, dynamic>;
                                            final replyId =
                                                snapshot.data!.docs[index].id;
                                            final contentReply =
                                                replyData['content'] ?? '';
                                            final userNameReply =
                                                replyData['userName'] ?? '';
                                            final avatarReply =
                                                replyData['avatar'] ?? '';
                                            final likeReply =
                                                replyData['like'] ?? 0;
                                            final Timestamp? replyTime =
                                                replyData['createdAt'];
                                            final DateTime replyCreatedAt =
                                                replyTime != null
                                                ? replyTime.toDate()
                                                : DateTime.now();
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                top: 10,
                                                left: 50,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      BuildAvatarComment(
                                                        url: avatarReply,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            UserNameComment(
                                                              nameFS:
                                                                  userNameReply,
                                                              isDark: isDark,
                                                            ),
                                                            CreatedAtComment(
                                                              createdAt:
                                                                  replyCreatedAt,
                                                              isDark: isDark,
                                                            ),
                                                            ContentComment(
                                                              isDark: isDark,
                                                              content:
                                                                  contentReply,
                                                            ),
                                                            SizedBox(height: 5),
                                                            CommentActionBar(
                                                              likeCount:
                                                                  likeReply,
                                                              targetRef: _commentRef
                                                                  .doc(
                                                                    commentId,
                                                                  )
                                                                  .collection(
                                                                    'replies',
                                                                  )
                                                                  .doc(replyId),
                                                              onReplyTap: () {
                                                                localSetState(() {
                                                                  replyingCommentId =
                                                                      commentId;
                                                                  replyingUserName =
                                                                      replyData['userName'];
                                                                  replyingUserId =
                                                                      replyData['userId'];
                                                                  showReplyInput[commentId] =
                                                                      !isShowReplyInput;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  );
                                },
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

class ContentComment extends StatelessWidget {
  const ContentComment({
    super.key,
    required this.isDark,
    required this.content,
  });

  final bool isDark;
  final dynamic content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? OkLab(0.28, -0.01, -0.03).toColor()
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
              : OkLab(0.45, -0.01, -0.03).toColor(),
        ),
      ),
    );
  }
}

class UserNameComment extends StatelessWidget {
  const UserNameComment({
    super.key,
    required this.nameFS,
    required this.isDark,
  });

  final String nameFS;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
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
    );
  }
}

class CreatedAtComment extends StatelessWidget {
  const CreatedAtComment({
    super.key,
    required this.createdAt,
    required this.isDark,
  });

  final DateTime createdAt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTime(createdAt),
      style: TextStyle(
        fontSize: 11,
        color: isDark
            ? OkLab(0.71, 0, -0.02).toColor()
            : OkLab(0.55, 0, -0.03).toColor(),
      ),
    );
  }
}

String formatTime(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return "${two(time.hour)}:${two(time.minute)} - ${time.day}/${time.month}/${time.year}";
}

class CommentActionBar extends StatelessWidget {
  final int likeCount;
  final DocumentReference targetRef;
  final VoidCallback onReplyTap;

  const CommentActionBar({
    super.key,
    required this.likeCount,
    required this.targetRef,
    required this.onReplyTap,
  });

  Future<void> toggleLike({required bool isLiked}) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final likeRef = targetRef.collection('likes').doc(userId);

    if (isLiked) {
      await Future.wait([
        likeRef.delete(),
        targetRef.update({'like': FieldValue.increment(-1)}),
      ]);
    } else {
      await Future.wait([
        likeRef.set({'userId': userId}),
        targetRef.update({'like': FieldValue.increment(1)}),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final likeRef = targetRef.collection('likes').doc(userId);

    return Row(
      children: [
        if (likeCount > 0)
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OkLab(0.93, -0.01, -0.03).toColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('👍'),
              ),
              SizedBox(width: 5),
              Text("$likeCount", style: TextStyle(fontSize: 12)),
            ],
          ),

        StreamBuilder<DocumentSnapshot>(
          stream: likeRef.snapshots(),
          builder: (context, snapshot) {
            final isLiked = snapshot.data?.exists ?? false;

            return Padding(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () async {
                  await toggleLike(isLiked: isLiked);
                },
                child: Row(
                  children: [
                    !isLiked
                        ? Icon(
                            Icons.thumb_up_off_alt_outlined,
                            size: 20,
                            color: OkLab(0.55, 0, -0.03).toColor(),
                            fontWeight: FontWeight.w600,
                          )
                        : Text('👍', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 5),
                    Text(
                      'Thích',
                      style: TextStyle(
                        color: !isLiked
                            ? OkLab(0.55, 0, -0.03).toColor()
                            : OkLab(0.62, -0.04, -0.21).toColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        Padding(
          padding: EdgeInsets.all(10),
          child: GestureDetector(
            onTap: onReplyTap,
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline_sharp,
                  size: 20,
                  color: OkLab(0.55, 0, -0.03).toColor(),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(width: 5),
                Text(
                  'Trả lời',
                  style: TextStyle(
                    color: OkLab(0.55, 0, -0.03).toColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BuildAvatarComment extends StatelessWidget {
  const BuildAvatarComment({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: url.isEmpty
          ? Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            )
          : Image.network(url, width: 40, height: 40, fit: BoxFit.cover),
    );
  }
}

class CommentInputBox extends StatelessWidget {
  final bool isDark;
  final String avatar;
  final String userName;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CommentInputBox({
    super.key,
    required this.isDark,
    required this.avatar,
    required this.userName,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              BuildAvatarComment(url: avatar),
              SizedBox(width: 10),
              Expanded(
                child: UserNameComment(nameFS: userName, isDark: isDark),
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
              onTap: onSubmit,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}
