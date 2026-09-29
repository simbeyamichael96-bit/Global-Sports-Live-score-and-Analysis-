import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(GlobalSportsLiveApp());
}

class GlobalSportsLiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Sports Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFF0F172A)),
      home: HomeScreen(),
    );
  }
}

class LiveMatch { String sport, league, homeTeam, awayTeam, homeScore, awayScore, time; LiveMatch({required this.sport, required this.league, required this.homeTeam, required this.awayTeam, required this.homeScore, required this.awayScore, required this.time}); }

class ApiService {
  static Future<List<LiveMatch>> fetchLiveGames() async {
    List<LiveMatch> all = [];
    try {
      var urls = {
        "Premier League": "https://site.api.espn.com/apis/site/v2/sports/soccer/eng.1/scoreboard",
        "La Liga": "https://site.api.espn.com/apis/site/v2/sports/soccer/esp.1/scoreboard",
        "NBA": "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard",
      };
      for (var e in urls.entries) {
        var res = await http.get(Uri.parse(e.value)).timeout(Duration(seconds: 8));
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          if (data['events']!= null) {
            for (var ev in data['events']) {
              var comp = ev['competitions'][0];
              var c = comp['competitors'];
              var home = c.firstWhere((x) => x['homeAway']=='home', orElse: ()=>c[0]);
              var away = c.firstWhere((x) => x['homeAway']=='away', orElse: ()=>c[1]);
              all.add(LiveMatch(sport: e.key.contains("NBA")?"NBA":"Football", league: e.key, homeTeam: home['team']['displayName'], awayTeam: away['team']['displayName'], homeScore: home['score']??"0", awayScore: away['score']??"0", time: comp['status']['type']['shortDetail']??"LIVE"));
            }
          }
        }
      }
    } catch(e){}
    return all.isEmpty? [LiveMatch(sport: "Football", league: "Premier League", homeTeam: "Man City", awayTeam: "Arsenal", homeScore: "2", awayScore: "1", time: "LIVE")] : all;
  }
}

class HomeScreen extends StatefulWidget { @override _HomeScreenState createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  List<LiveMatch> matches = [];
  bool loading = true;
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;

  final String bannerId = "ca-app-pub-6198433078225470/9286549765";
  final String interstitialId = "ca-app-pub-6198433078225470/1655417753";
  final String rewardedId = "ca-app-pub-6198433078225470/6572756518";

  @override
  void initState() {
    super.initState();
    loadAds();
    loadGames();
  }

  void loadAds() {
    BannerAd(adUnitId: bannerId, size: AdSize.banner, request: AdRequest(), listener: BannerAdListener(onAdLoaded: (ad){setState(()=>bannerAd=ad as BannerAd);})).load();
    InterstitialAd.load(adUnitId: interstitialId, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad)=>interstitialAd=ad, onAdFailedToLoad: (e){}));
    RewardedAd.load(adUnitId: rewardedId, request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad)=>rewardedAd=ad, onAdFailedToLoad: (e){}));
  }

  Future<void> loadGames() async { setState(()=>loading=true); var d=await ApiService.fetchLiveGames(); setState((){matches=d; loading=false;}); }

  void showInterstitial() { if(interstitialAd!=null){interstitialAd!.show(); interstitialAd=null; loadAds();} }
  void showRewarded(Function onReward) { if(rewardedAd!=null){rewardedAd!.show(onUserEarnedReward: (ad,reward){onReward();});} else {onReward();} }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(title: Text("GLOBAL SPORTS LIVE 💰"), backgroundColor: Color(0xFF1E293B)),
      body: Column(children: [
        if(bannerAd!=null) Container(height: 50, child: AdWidget(ad: bannerAd!)),
        Expanded(child: loading?Center(child: CircularProgressIndicator()): ListView.builder(itemCount: matches.length, itemBuilder: (c,i){
          var m=matches[i];
          return Card(color: Color(0xFF1E293B), child: ListTile(onTap: (){showInterstitial(); showRewarded((){ Navigator.push(context, MaterialPageRoute(builder: (_)=> DetailPage(match: m))); }); }, title: Text("${m.homeTeam} vs ${m.awayTeam}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text("${m.league} | ${m.time} - Bofya kufungua VIP", style: TextStyle(color: Colors.green)), trailing: Text("${m.homeScore}-${m.awayScore}", style: TextStyle(color: Colors.white, fontSize: 18))));
        })),
        if(bannerAd!=null) Container(height: 50, child: AdWidget(ad: bannerAd!)),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: loadGames, child: Icon(Icons.refresh)),
    );
  }
}

class DetailPage extends StatelessWidget {
  final LiveMatch match;
  DetailPage({required this.match});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("VIP Analysis - LIVE")), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("${match.homeTeam} ${match.homeScore} - ${match.awayScore} ${match.awayTeam}", style: TextStyle(color: Colors.white, fontSize: 24)), SizedBox(height:20), Text("Umefungua kwa kuangalia Ad - Pesa imeingia!", style: TextStyle(color: Colors.green))])), backgroundColor: Color(0xFF0F172A),);
  }
}
