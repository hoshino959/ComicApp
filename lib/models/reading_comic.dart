import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReadingComic {
  static Future<void> saveProgress({
    required String comicId,
    required String comicTitle,
    required String coverUrl,
    required String chapterId,
    required String chapterTitle,
    required int chapterIndex,
    required int totalChapters,
    required String status,
  }) async {
    double progress = chapterIndex / totalChapters;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Reading')
        .doc(comicId)
        .get();
    if (!doc.exists) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Reading')
          .doc(comicId)
          .set({
            'comicId': comicId,
            'comicTitle': comicTitle,
            'coverUrl': coverUrl,
            'chapterId': chapterId,
            'chapterTitle': chapterTitle,
            'chapterIndex': chapterIndex,
            'totalChapters': totalChapters,
            'progress': progress,
            'updatedAt': FieldValue.serverTimestamp(),
            'status': status,
          });
    } else {
      final data = doc.data()!;

      if (chapterIndex < data['chapterIndex']) return;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Reading')
          .doc(comicId)
          .update({
            'chapterId': chapterId,
            'chapterTitle': chapterTitle,
            'chapterIndex': chapterIndex,
            'progress': progress,
            'updatedAt': FieldValue.serverTimestamp(),
            'status': status,
          });
    }
  }

  final String comicId;
  final String comicTitle;
  final String coverUrl;
  final String chapterTitle;
  final int chapterIndex;
  final int totalChapters;
  final double progress;
  final String status;

  ReadingComic({
    required this.comicId,
    required this.comicTitle,
    required this.coverUrl,
    required this.chapterTitle,
    required this.chapterIndex,
    required this.totalChapters,
    required this.progress,
    required this.status,
  });

  Future loadDetailComic() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Reading')
        .doc(comicId)
        .get();
    if (!doc.exists) return null;

    final data = doc.data()!;

    return ReadingComic(
      comicId: data['comicId'],
      comicTitle: data['comicTitle'],
      coverUrl: data['coverUrl'],
      chapterTitle: data['chapterTitle'],
      chapterIndex: data['chapterIndex'],
      totalChapters: data['totalChapters'],
      progress: (data['progress'] as num).toDouble(),
      status: data['status'],
    );
  }

  static Future<void> pushNew({
    required String comicId,
    required String comicTitle,
    required String coverUrl,
    required String chapterId,
    required String chapterTitle,
    required int chapterIndex,
    required int totalChapters,
    required String status,
  }) async {
    double progress = chapterIndex / totalChapters;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Reading')
        .doc(comicId)
        .set({
          'comicId': comicId,
          'comicTitle': comicTitle,
          'coverUrl': coverUrl,
          'chapterId': chapterId,
          'chapterTitle': chapterTitle,
          'chapterIndex': chapterIndex,
          'totalChapters': totalChapters,
          'progress': progress,
          'updatedAt': FieldValue.serverTimestamp(),
          'status': status,
        });
  }

  static Future<void> deleteReading({
    required String comicId,
    required String collection,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection(collection)
        .doc(comicId)
        .delete();
  }

  static Future<void> addLibrary({
    required String comicId,
    required String comicTitle,
    required String coverUrl,
    required String chapterTitle,
    required int totalChapters,
    required String status,
    required String collection,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection(collection)
        .doc(comicId)
        .set({
          'comicId': comicId,
          'comicTitle': comicTitle,
          'coverUrl': coverUrl,
          'chapterTitle': chapterTitle,
          'totalChapters': totalChapters,
          'updatedAt': FieldValue.serverTimestamp(),
          'status': status,
        });
  }
}
