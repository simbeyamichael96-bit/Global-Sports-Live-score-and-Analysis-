import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';

const API_KEY = "e747e4108a3f5543924daf0ab654f865";

// AdMob ID ZAKO HALISI
const BANNER_ID = "ca-app-pub-6198433078225470/9286549765";
const INTERSTITIAL_ID = "ca-app-pub-6198433078225470/1655471753";
const REWARDED_ID = "ca-app-pub-6198433078225470/6572756518";
const NATIVE_ID = "ca-app-pub-6198433078225470/6043021903";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(GlobalSportsLiveMoneyApp());
}

class GlobalSportsLiveMoneyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Sports Live',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0F0F0F)),
      home: MoneyScreen(),
    );
  }
}

class MoneyScreen extends StatefulWidget {
  @override
  _MoneyScreenState createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List footballLive = [];
  List basketballLive = [];
  List baseballLive = [];
  bool loading = true;
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  int tabClicks = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadAds();
    fetchAllSportsMoney();
    _tabController.addListener(() {
      tabClicks++;
      if (tabClicks % 2 == 0) showInterstitial();
    });
  }

  void loadAds() {
    bannerAd = BannerAd(adUnitId: BANNER_ID, size: AdSize.banner, request: AdRequest(), listener: BannerAdListener())..load();
    InterstitialAd.load(adUnitId: INTERSTITIAL_ID, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => interstitialAd = ad, onAdFailedToLoad: (e) {}));
    RewardedAd.load(adUnitId: REWARDED_ID, request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) => rewardedAd = ad, onAdFailedToLoad: (e) {}));
  }

  void showInterstitial() {
    if (interstitialAd!= null) {
      interstitialAd!.show();
      InterstitialAd.load(adUnitId: INTERSTITIAL_ID, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => interstitialAd = ad, onAdFailedToLoad: (e) {}));
    }
  }

  Future fetchAllSportsMoney() async {
    setState(() => loading = true);
    try {
      // FOOTBALL LIVE - Mechi zote duniani LIVE
      final f = await http.get(Uri.parse("https://v3.football.api-sports.io/fixtures?live=all"), headers: {"x-apisports-key": API_KEY});
      if (f.statusCode == 200) footballLive = json.decode(f.body)['response']?? [];

      // BASKETBALL LIVE - NBA LIVE
      final b = await http.get(Uri.parse("https://v1.basketball.api-sports.io/games?live=all"), headers: {"x-apisports-key": API_KEY});
      if (b.statusCode == 200) basketballLive = json.decode(b.body)['response']?? [];

      // BASEBALL LIVE
      final bb = await http.get(Uri.parse("https://v1.baseball.api-sports.io/games?live=all"), headers: {"x-apisports-key": API_KEY});
      if (bb.statusCode == 200) baseballLive = json.decode(bb.body)['response']?? [];
    } catch (e) {}
    setState(() => loading = false);
  }

  Widget buildMatchList(List matches, String sport) {
    if (loading) return Center(child: CircularProgressIndicator(color: Colors.green));
    if (matches.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.sports_soccer, size: 60, color: Colors.grey), SizedBox(height: 10), Text("Hakuna $sport LIVE sasa", style: TextStyle(color: Colors.white70)), ElevatedButton(onPressed: fetchAllSportsMoney, child: Text("Refresh"))]));
    return RefreshIndicator(onRefresh: fetchAllSportsMoney, child: ListView.builder(itemCount: matches.length, itemBuilder: (c,i){
      final m = matches[i];
      String home, away, score, league, minute;
      if (sport == "FOOTBALL") {
        home = m['teams']['home']['name']; away = m['teams']['away']['name'];
        score = "${m['goals']['home']?? 0} - ${m['goals']['away']?? 0}";
        league = m['league']['name']; minute = "${m['fixture']['status']['elapsed']?? 0}'";
      } else {
        home = m['teams']['home']['name']?? "Home"; away = m['teams']['away']['name']?? "Away";
        score = "${m['scores']['home']['total']?? 0} - ${m['scores']['away']['total']?? 0}";
        league = m['league']['name']?? sport; minute = m['status']['short']?? "LIVE";
      }
      // Native Ad kila mechi 4 - inalipa zaidi
      if (i>0 && i % 4 == 0) {
        return Column(children: [
          Container(height: 80, color: Colors.grey[900], child: Center(child: Text("🔥 Native Ad - $NATIVE_ID", style: TextStyle(color: Colors.yellow)))),
          matchCard(home, away, score, league, minute)
        ]);
      }
      return matchCard(home, away, score, league, minute);
    }));
  }

  Widget matchCard(String home, String away, String score, String league, String minute) {
    return Card(color: Color(0xFF1E1E1E), margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: ListTile(
      onTap: () {
        // Kila click 3 - Interstitial - PESA
        if (tabClicks % 3 == 0) showInterstitial();
        // Kila click 5 - Rewarded VIP Unlock - PESA KUBWA
        if (tabClicks % 5 == 0 && rewardedAd!= null) {
          rewardedAd!.show(onUserEarnedReward: (a, r) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("VIP Unlocked! 1 Live Access")));
          });
        }
      },
      leading: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: Text(minute, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
      title: Text("$home vs $away", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(league, style: TextStyle(fontSize: 11, color: Colors.white60)), Text(score, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent))]),
      trailing: Icon(Icons.live_tv, color: Colors.red),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🌍 GLOBAL LIVE - PESA APP"),
        backgroundColor: Colors.green[900],
        bottom: TabBar(controller: _tabController, isScrollable: true, tabs: [
          Tab(text: "⚽ FOOT (${footballLive.length})"),
          Tab(text: "🏀 BASKET (${basketballLive.length})"),
          Tab(text: "⚾ BASEBALL (${baseballLive.length})"),
          Tab(text: "🏁 F1 / VIP"),
        ]),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: fetchAllSportsMoney)],
      ),
      body: Column(children: [
        if (bannerAd!= null) Container(height: 50, child: AdWidget(ad: bannerAd!)),
        Expanded(child: TabBarView(controller: _tabController, children: [
          buildMatchList(footballLive, "FOOTBALL"),
          buildMatchList(basketballLive, "BASKETBALL"),
          buildMatchList(baseballLive, "BASEBALL"),
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.workspace_premium, size: 80, color: Colors.amber),
            SizedBox(height: 20),
            Text("VIP LIVE UNLOCK", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Tazama mechi zote 8 bila kikomo", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)), onPressed: () { if (rewardedAd!= null) rewardedAd!.show(onUserEarnedReward: (a,r){}); }, child: Text("WATCH AD TO UNLOCK VIP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
          ]))
        ]))
      ]),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.green, onPressed: fetchAllSportsMoney, child: Icon(Icons.refresh)),
    );
  }
}
