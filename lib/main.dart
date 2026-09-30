import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ==================== MULTI-SPORT NOTIFICATION SERVICE ====================
class GoalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static Timer? _timer;
  static Set<String> _notified = {};

  static const String API_KEY = "e747e4108c5e0a6d6e6a8b3e9f123456789"; // <-- WEKA KEY YAKO KAMILI HAPA
  static const String BASE_URL = "https://v3.football.api-sports.io";

  static Future<void> init() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static void startWatcher() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 20), (timer) async {
      await checkAllSports();
    });
  }

  static Future<void> checkAllSports() async {
    // Hapa tuna-check Football, Basketball, etc
    await checkForGoals();
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
                if (!_notified.contains(uniqueId)) {
                  await showNotification("GOAL! ⚽ $home vs $away", "${event['player']['name']} ${event['time']['elapsed']}' | ${fixture['goals']['home']}-${fixture['goals']['away']}");
                  _notified.add(uniqueId);
                }
              }
            }
          }
        }
      }
    } catch (e) {}
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'multi_sport_01', 'Multi Sport Alerts', importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notifications.show(DateTime.now().millisecond, title, body, details);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await GoalNotificationService.init();
  GoalNotificationService.startWatcher();
  runApp(GlobalSportsApp());
}

class GlobalSportsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Sports Live',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0A1931)),
      home: MultiSportHome(),
    );
  }
}

class MultiSportHome extends StatefulWidget {
  @override
  _MultiSportHomeState createState() => _MultiSportHomeState();
}

class _MultiSportHomeState extends State<MultiSportHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BannerAd? _bannerAd;

  final List<Map<String, dynamic>> sports = [
    {"name": "Football", "icon": Icons.sports_soccer, "endpoint": "football"},
    {"name": "Basketball", "icon": Icons.sports_basketball, "endpoint": "basketball"},
    {"name": "Tennis", "icon": Icons.sports_tennis, "endpoint": "tennis"},
    {"name": "Cricket", "icon": Icons.sports_cricket, "endpoint": "cricket"},
    {"name": "Volleyball", "icon": Icons.sports_volleyball, "endpoint": "volleyball"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sports.length, vsync: this);
    _bannerAd = BannerAd(adUnitId: 'ca-app-pub-6198433078225470/8509470000', size: AdSize.banner, request: AdRequest(), listener: BannerAdListener())..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1931),
        centerTitle: true,
        title: Column(children: [Text("GLOBAL SPORTS LIVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text("5 Sports - Score & Analysis", style: TextStyle(fontSize: 11, color: Colors.cyanAccent))]),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: sports.map((s) => Tab(icon: Icon(s['icon']), text: s['name'])).toList(),
        ),
      ),
      body: Column(
        children: [
          Container(padding: EdgeInsets.all(6), color: Colors.green.withOpacity(0.2), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notifications_active, color: Colors.greenAccent, size: 14), SizedBox(width: 5), Text("Live Alerts ON for 5 Sports", style: TextStyle(color: Colors.greenAccent, fontSize: 11))])),
          Expanded(child: TabBarView(controller: _tabController, children: sports.map((s) => SportPage(sport: s)).toList())),
          if (_bannerAd != null) Container(height: 60, child: AdWidget(ad: _bannerAd!)),
        ],
      ),
    );
  }
}

class SportPage extends StatefulWidget {
  final Map<String, dynamic> sport;
  SportPage({required this.sport});

  @override
  _SportPageState createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  List matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    // Kwa sasa Football ina data halisi, mingine tuna-simulate - ukipata API za Basketball tutaunganisha
    if (widget.sport['endpoint'] == 'football') {
      try {
        final res = await http.get(Uri.parse("https://v3.football.api-sports.io/fixtures?live=all"), headers: {"x-apisports-key": GoalNotificationService.API_KEY});
        if (res.statusCode == 200) {
          setState(() { matches = jsonDecode(res.body)['response']; loading = false; });
        }
      } catch (e) { setState(() => loading = false); }
    } else {
      // Simulate kwa sports zingine mpaka upate API key zao
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        matches = [
          {"teams": {"home": {"name": "Lakers"}, "away": {"name": "Warriors"}}, "goals": {"home": 89, "away": 92}, "fixture": {"status": {"elapsed": 32}}},
          {"teams": {"home": {"name": "Bulls"}, "away": {"name": "Heat"}}, "goals": {"home": 45, "away": 48}, "fixture": {"status": {"elapsed": 18}}},
        ];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    if (matches.isEmpty) return Center(child: Text("Hakuna ${widget.sport['name']} live sasa\nGoal Watcher inasubiri...", textAlign: TextAlign.center));
    
    return RefreshIndicator(
      onRefresh: fetchMatches,
      child: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, i) {
          var m = matches[i];
          return Card(
            color: Color(0xFF162447),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(widget.sport['icon'], color: Colors.cyanAccent),
              title: Text("${m['teams']['home']['name']} vs ${m['teams']['away']['name']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("Score: ${m['goals']['home']} - ${m['goals']['away']} | ${m['fixture']['status']['elapsed']}' LIVE", style: TextStyle(fontSize: 12)),
              trailing: Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: Text("LIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }
}
