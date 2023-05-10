import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sore_beta_1/ui/main_pages/profile_screen.dart';
import 'package:sore_beta_1/ui/main_pages/home_screen.dart';
import 'package:sore_beta_1/ui/main_pages/base_screen.dart';
import 'package:sore_beta_1/ui/main_pages/analytics_page.dart';


class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  static const Color color1 = Color(0xFF13588F);
  static const Color color3 = Color(0xffd4eff5);


  final auth = FirebaseAuth.instance;
  late User? user;

  List pages = [
    HomeScreen(),
    BaseScreen(),
    AnalyticsPage(),
    ProfileScreen()
  ];

  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = auth.currentUser;
    pages[1] = BaseScreen();

    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      body: pages[currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          clipBehavior: Clip.hardEdge, //or better look(and cost) using Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(23),
              topLeft: Radius.circular(23),
              bottomLeft: Radius.circular(23),
              bottomRight: Radius.circular(23),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: color1,
            type: BottomNavigationBarType.fixed,
            onTap: onTap,
            currentIndex: currentIndex,
            iconSize: 25,
            selectedFontSize: 13,
            selectedIconTheme: IconThemeData(color: Colors.white, size: 35),
            selectedItemColor: Colors.white,
            unselectedItemColor: color3,
            items: const [
              BottomNavigationBarItem(label:'Басты бет', icon: Icon(Icons.home)),
              BottomNavigationBarItem(label:'Қойма', icon: Icon(Icons.apps)),
              BottomNavigationBarItem(label:'Анализ', icon: Icon(Icons.analytics)),
              BottomNavigationBarItem(label:'Профиль', icon: Icon(Icons.people))
            ],
          ),
        ),
      ),
    );
  }
}
