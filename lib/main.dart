import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const GlobalSportsApp());
}

class GlobalSportsApp extends StatelessWidget {
  const GlobalSportsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Sports LIVE',
      theme: ThemeData(primarySwatch: Colors.red, scaffoldBackgroundColor: Color(0xFF0F0F0F)),
      home: const HomeScreen(),
    );
  }
}

// ==================== MODELS ====================
class LiveMatch {
  final String sport, league, homeTeam, awayTeam, homeScore, awayScore, time, status;
  LiveMatch({required this.sport, required this.league, required this.homeTeam, required this.awayTeam, required this.homeScore, required this.awayScore, required this.time, required this.status});
}

// ==================== API 42 LIGI ====================
class ApiService {
  static const String apiKey = "e747e4108a3f5543924daf0ab654f865";

  static Future<List<LiveMatch>> fetchLiveGames() async {
    List<LiveMatch> all = [];
    // 1. FOOTBALL LIVE
    try {
      var res = await http.get(
        Uri.parse("https://v3.football.api-sports.io/fixtures?live=all"),
        headers: {"x-apisports-key": apiKey},
      ).timeout(const Duration(seconds: 12));
      
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        for (var f in data['response'] ?? []) {
          all.add(LiveMatch(
            sport: "Football",
            league: f['league']['name'] ?? "League",
            homeTeam: f['teams']['home']['name'] ?? "Home",
            awayTeam: f['teams']['away']['name'] ?? "Away",
            homeScore: "${f['goals']['home'] ?? 0}",
            awayScore: "${f['goals']['away'] ?? 0}",
            time: f['fixture']['status']['short'] == "FT" ? "FT" : "${f['fixture']['status']['elapsed'] ?? 0}'",
            status: f['fixture']['status']['long'] ?? "LIVE",
          ));
        }
      }
    } catch (e) { debugPrint("Football Error $e"); }

    // 2. BASKETBALL LIVE (NBA)
    if (all.length < 5) {
      try {
        var res = await http.get(
          Uri.parse("https://v1.basketball.api-sports.io/games?live=all"),
          headers: {"x-apisports-key": apiKey},
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          for (var g in data['response'] ?? []) {
            all.add(LiveMatch(
              sport: "Basketball",
              league: g['league']['name'] ?? "NBA",
              homeTeam: g['teams']['home']['name'] ?? "Home",
              awayTeam: g['teams']['away']['name'] ?? "Away",
              homeScore: "${g['scores']['home']['total'] ?? 0}",
              awayScore: "${g['scores']['away']['total'] ?? 0}",
              time: "Q${g['periods']['current'] ?? 1}",
              status: "LIVE",
            ));
          }
        }
      } catch (e) {}
    }

    // Demo kama hakuna LIVE saa hii
    if (all.isEmpty) {
      all = [
        LiveMatch(sport: "Football", league: "Premier League", homeTeam: "Man City", awayTeam: "Arsenal", homeScore: "2", awayScore: "1", time: "78'", status: "LIVE"),
        LiveMatch(sport: "Football", league: "La Liga", homeTeam: "Real Madrid", awayTeam: "Barcelona", homeScore: "1", awayScore: "1", time: "45'", status: "LIVE"),
        LiveMatch(sport: "Football", league: "Serie A", homeTeam: "Inter", awayTeam: "AC Milan", homeScore: "0", awayScore: "0", time: "12'", status: "LIVE"),
        LiveMatch(sport: "Basketball", league: "NBA", homeTeam: "Lakers", awayTeam: "Warriors", homeScore: "98", awayScore: "102", time: "Q4", status: "LIVE"),
        LiveMatch(sport: "Football", league: "Saudi Pro", homeTeam: "Al Nassr", awayTeam: "Al Hilal", homeScore: "3", awayScore: "2", time: "FT", status: "Finished"),
      ];
    }
    return all;
  }
}

// ==================== ADS ZAKO 4 HALISI ====================
class AdHelper {
  static const bannerId = "ca-app-pub-6198433078225470/9286549765";
  static const interstitialId = "ca-app-pub-6198433078225470/1655471753";
  static const nativeId = "ca-app-pub-6198433078225470/6043021903";
  static const rewardedId = "ca-app-pub-6198433078225470/6572756518";
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LiveMatch> matches = [];
  List<LiveMatch> filtered = [];
  bool loading = true;
  String selectedSport = "All";

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadAds();
    _loadGames();
  }

  void _loadAds() {
    _bannerAd = BannerAd(adUnitId: AdHelper.bannerId, size: AdSize.banner, request: const AdRequest(), listener: BannerAdListener())..load();
    InterstitialAd.load(adUnitId: AdHelper.interstitialId, request: const AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => _interstitialAd = ad, onAdFailedToLoad: (e) => debugPrint("Inter $e")));
    RewardedAd.load(adUnitId: AdHelper.rewardedId, request: const AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) => _rewardedAd = ad, onAdFailedToLoad: (e) => debugPrint("Reward $e")));
  }

  Future<void> _loadGames() async {
    setState(() => loading = true);
    var data = await ApiService.fetchLiveGames();
    setState(() { matches = data; filtered = data; loading = false; });
  }

  void _filter(String sport) {
    setState(() {
      selectedSport = sport;
      if (sport == "All") { filtered = matches; } else { filtered = matches.where((m) => m.sport == sport).toList(); }
    });
  }

  void _showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      InterstitialAd.load(adUnitId: AdHelper.interstitialId, request: const AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => _interstitialAd = ad, onAdFailedToLoad: (e) {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Sports LIVE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.red[700],
        actions: [IconButton(onPressed: _loadGames, icon: const Icon(Icons.refresh, color: Colors.white))],
      ),
      bottomNavigationBar: _bannerAd == null ? null : SizedBox(height: 50, child: AdWidget(ad: _bannerAd!)),
      body: Column(
        children: [
          // FILTER CHIPS
          SizedBox(height: 50, child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            children: ["All", "Football", "Basketball"].map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(s), selected: selectedSport == s, onSelected: (v){ _filter(s); _showInterstitial(); }),
            )).toList(),
          )),
          Expanded(
            child: loading ? const Center(child: CircularProgressIndicator(color: Colors.red)) :
            RefreshIndicator(onRefresh: _loadGames, child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (c, i) {
                var m = filtered[i];
                bool isLive = m.status.contains("LIVE") || m.time.contains("'") || m.time.contains("Q");
                return Card(
                  color: Color(0xFF1E1E1E), margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      if (i % 3 == 0) _showInterstitial();
                      // Native ad katikati baada ya mchezo wa 2
                    },
                    leading: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: isLive ? Colors.red : Colors.grey, borderRadius: BorderRadius.circular(4)), child: Text(isLive ? "LIVE" : "FT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                    title: Text("${m.homeTeam} vs ${m.awayTeam}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("${m.league} • ${m.time}", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      if ((i+1) % 4 == 0) Container(margin: EdgeInsets.only(top:6), padding: EdgeInsets.all(4), color: Colors.yellow[700], child: Text("AD: ${AdHelper.nativeId.split('/').last} - Native Ad hapa", style: TextStyle(fontSize: 10))),
                    ]),
                    trailing: Column(children: [
                      Text("${m.homeScore} - ${m.awayScore}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      GestureDetector(onTap: (){
                        _rewardedAd?.show(onUserEarnedReward: (a,r){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("VIP Unlocked! Umetazama ${m.homeTeam} vs ${m.awayTeam} LIVE"))); });
                      }, child: Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)), child: Text("VIP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                    ]),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
  @override void dispose(){ _bannerAd?.dispose(); _interstitialAd?.dispose(); _rewardedAd?.dispose(); super.dispose(); }
}
