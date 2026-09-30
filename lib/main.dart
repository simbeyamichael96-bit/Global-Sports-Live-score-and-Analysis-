import 'package:flutter/material.dart';

void main() {
  runApp(const GlobalSportsLive());
}

class GlobalSportsLive extends StatelessWidget {
  const GlobalSportsLive({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Sports Live',
      theme: ThemeData(
        primaryColor: const Color(0xFF0A1931),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_full.png', width: 280),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF0A1931)),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1931),
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 35),
            const SizedBox(width: 10),
            const Text('Global Sports Live', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_full.png', width: 200),
            const SizedBox(height: 20),
            const Text('Welcome!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Global Sports Live - Realistic'),
          ],
        ),
      ),
    );
  }
}
