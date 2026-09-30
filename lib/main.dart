import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ==================== GOAL NOTIFICATION SERVICE NDANI YA MAIN.DART ====================
class GoalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static Timer? _timer;
  static Set<String> _notifiedGoals = {};

  static const String API_KEY = "e747e4108c5e0a6d6e6a8b3e9f123456789"; // <-- BADILISHA HAPA WEKA KEY YAKO KAMILI
  static const String BASE_URL = "https://v3.football.api-sports.io";

  static Future<void> init() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static void startGoalWatcher() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 20), (timer) async {
      await checkForGoals();
    });
  }

  static Future<void> checkForGoals() async {
    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/fixtures?live=all"),
        headers: {"x-apisports-key": API_KEY},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var fixture in data['response']) {
          int fixtureId = fixture['fixture']['id'];
          String home = fixture['teams']['home']['name'];
          String away = fixture['teams']['away']['name'];

          final eventsRes = await http.get(
            Uri.parse("$BASE_URL/fixtures/events?fixture=$fixtureId"),
            headers: {"x-apisports-key": API_KEY},
          );

          if (eventsRes.statusCode == 200) {
            final eventsData = jsonDecode(eventsRes.body);
            for (var event in eventsData['response']) {
              if (event['type'] == 'Goal') {
                String uniqueId = "$fixtureId-${event['time']['elapsed']}-${event['player']['id']}";
                if (!_notifiedGoals.contains(uniqueId)) {
                  String scorer = event['player']['name'];
                  int minute = event['time']['elapsed']?? 0;
                  String score = "${fixture['goals']['home']} - ${fixture['goals']['away']}";
                  await showGoalNotification(home, away, scorer, minute, score);
                  _notifiedGoals.add(uniqueId);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("Goal check error: $e");
    }
  }

  static Future<void> showGoalNotification(String home, String away, String scorer, int minute, String score) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'goal_channel_01',
      'Goal Alerts',
      channelDescription: 'Instant goal notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      DateTime.now().millisecond,
      "GOAL! ⚽ $home vs $away",
      "$scorer $minute' | $score",
      details,
    );
  }
}
// ==================== MWISHO WA NOTIFICATION SERVICE ====================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await GoalNotificationService.init();
  GoalNotificationService.startGoalWatcher();
  runApp(GlobalSportsApp());
}

class GlobalSportsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Sports Live',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0A1931)),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  List liveMatches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBanner();
    fetchLiveMatches();
  }

  void loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6198433078225470/8509470000',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  Future<void> fetchLiveMatches() async {
    try {
      final res = await http.get(
        Uri.parse("https://v3.football.api-sports.io/fixtures?live=all"),
        headers: {"x-apisports-key": GoalNotificationService.API_KEY},
      );
      if (res.statusCode == 200) {
        setState(() {
          liveMatches = jsonDecode(res.body)['response'];
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1931),
        centerTitle: true,
        title: Column(
          children: [
            Text("GLOBAL SPORTS LIVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
            Text("Score & Match Analysis", style: TextStyle(fontSize: 11, color: Colors.cyanAccent)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.green.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active, color: Colors.greenAccent, size: 16),
                SizedBox(width: 5),
                Text("Goal Notifications ON - Kila 20 sec", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: loading
               ? Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                : liveMatches.isEmpty
                   ? Center(child: Text("Hakuna mechi live sasa - Goal Watcher inasubiri..."))
                    : ListView.builder(
                        itemCount: liveMatches.length,
                        itemBuilder: (context, i) {
                          var m = liveMatches[i];
                          return Card(
                            color: Color(0xFF162447),
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text("${m['teams']['home']['name']} vs ${m['teams']['away']['name']}", style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Score: ${m['goals']['home']} - ${m['goals']['away']} | ${m['fixture']['status']['elapsed']}'"),
                              trailing: Icon(Icons.live_tv, color: Colors.red),
                            ),
                          );
                        },
                      ),
          ),
          if (_bannerAd!= null) Container(height: 60, child: AdWidget(ad: _bannerAd!)),
        ],
      ),
    );
  }
}
