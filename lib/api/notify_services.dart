import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/api/api_service.dart';
import 'package:comic_app/models/chapter_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifyServices {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> checkChapterNews() async {
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Notification')
        .get();

    for (var doc in snapshot.docs) {
      final comicId = doc.id;
      final totalChaptersFS = doc['totalChapters'] ?? 0;

      final chapters = await ApiService.fetchAllComicChapters(comicId);
      final comicDetail = await ApiService.fetchComicDetail(comicId);

      if (chapters.isEmpty) continue;

      final totalChaptersAPI = chapters.length;

      if (totalChaptersFS < totalChaptersAPI) {
        final sortedChapters = List<ChapterModel>.from(chapters);
        sortedChapters.sort((a, b) => b.publishDate.compareTo(a.publishDate));
        final diff = (totalChaptersAPI - totalChaptersFS).toInt();
        final newChapters = sortedChapters.take(diff).toList();
        for (var chap in newChapters) {
          final docRef = FirebaseFirestore.instance
              .collection('Notification')
              .doc(user!.uid)
              .collection(comicId)
              .doc(chap.id);
          final exists = await docRef.get();
          if (exists.exists) continue;
          await docRef.set({
            'comicId': comicId,
            'comicTitle': comicDetail?.title,
            'coverUrl': comicDetail?.coverUrl,
            'chapter': chap.chapterTitle,
            'chapterId': chap.id,
            'publishDate': chap.publishDate,
            'updatedAt': FieldValue.serverTimestamp(),
            'status': false,
          });
        }
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('Notification')
            .doc(comicId)
            .update({'totalChapters': chapters.length});
      }
    }
  }
}
