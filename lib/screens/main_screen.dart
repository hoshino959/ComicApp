import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/screens/notify_screen.dart';
import 'package:comic_app/screens/search_screen.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/screens/home_screen.dart';
import 'package:comic_app/user/user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool hasUnread = false;
  final user = FirebaseAuth.instance.currentUser;

  List<Widget> get _widgetOptions => [
    const HomeScreen(),
    const SearchScreen(),
    if (user != null) NotifyScreen(onRefresh: () => setState(() {})),
    const UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Stream<bool> hasUnReadNotifications() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Notification')
        .snapshots()
        .asyncMap((comicSnapshot) async {
          for (var comicDoc in comicSnapshot.docs) {
            final comicId = comicDoc.id;

            final chapterSnapshot = await FirebaseFirestore.instance
                .collection('Notification')
                .doc(user!.uid)
                .collection(comicId)
                .where('status', isEqualTo: false)
                .limit(1)
                .get();
            if (chapterSnapshot.docs.isNotEmpty) {
              return true;
            }
          }
          return false;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: AppColors.primaryPink,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          if (user != null)
            BottomNavigationBarItem(
              icon: StreamBuilder<bool>(
                stream: hasUnReadNotifications(),
                builder: (context, snapshot) {
                  bool hasUnread = snapshot.data ?? false;
                  return Stack(
                    children: [
                      Icon(Icons.notifications_none),
                      if (hasUnread)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              activeIcon: StreamBuilder<bool>(
                stream: hasUnReadNotifications(),
                builder: (context, snapshot) {
                  bool hasUnread = snapshot.data ?? false;
                  return Stack(
                    children: [
                      Icon(Icons.notifications),
                      if (hasUnread)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: 'Thông báo',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
