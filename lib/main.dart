import 'package:flutter/material.dart';

void main() {
  runApp(GlobalSportsLiveApp());
}

class GlobalSportsLiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Sports Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0A4A7A), // Blue Bahari Deep
        scaffoldBackgroundColor: Color(0xFF001F3F),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0A4A7A),
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF001F3F),
          selectedItemColor: Color(0xFF00E5FF), // Neon Blue
          unselectedItemColor: Colors.white54,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _sportsPages = [
    FootballLivePage(),
    BasketballPage(),
    TennisPage(),
    HockeyPage(),
    CricketPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Global Sports Live'),
            Text('Score & Match Analysis', 
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF00E5FF))),
          ],
        ),
        actions: [
          Icon(Icons.live_tv, color: Color(0xFF00E5FF)),
          SizedBox(width: 16),
        ],
      ),
      body: _sportsPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Football'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_basketball), label: 'NBA'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'Tennis'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_hockey), label: 'Hockey'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_cricket), label: 'Cricket'),
        ],
      ),
    );
  }
}

// PLACEHOLDER PAGES - Data yako ya LIVE itaenda hapa
class FootballLivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('⚽ Football Live Scores & Analysis', style: TextStyle(color: Colors.white, fontSize: 18)));
  }
}
class BasketballPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('🏀 NBA Live Scores', style: TextStyle(color: Colors.white)));
  }
}
class TennisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('🎾 Tennis Live', style: TextStyle(color: Colors.white)));
  }
}
class HockeyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('🏒 Hockey Live', style: TextStyle(color: Colors.white)));
  }
}
class CricketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('🏏 Cricket Live', style: TextStyle(color: Colors.white)));
  }
}
