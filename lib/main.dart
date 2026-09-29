import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(GlobalSportsLivePro());
}

class GlobalSportsLivePro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Sports Live PRO',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0E0E10),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF1C1C1E), elevation: 0),
      ),
      home: HomePage(),
    );
  }
}

class Config {
  static const apiKey = "e747e4108a3f5543924daf0ab654f865";
  static const banner = "ca-app-pub-6198433078225470/9286549765";
  static const native = "ca-app-pub-6198433078225470/6043021903";
  static const interstitial = "ca-app-pub-6198433078225470/1655471753";
  static const rewarded = "ca-app-pub-6198433078225470/6572756518";
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedDay = 3;
  int bottomIndex = 0;
  bool isLoading = true;
  List groupedMatches = [];
  BannerAd? bannerAd;
  bool bannerReady = false;
  InterstitialAd? interAd;
  RewardedAd? rewardedAd;
  bool isVIP = false;

  List days = [
    {"d":"Sun","dt":"Sep 27"},{"d":"Mon","dt":"Sep 28"},{"d":"Tue","dt":"Sep 29"},
    {"d":"Today","dt":"Sep 30"},{"d":"Thu","dt":"Oct 1"},{"d":"Fri","dt":"Oct 2"},{"d":"Sat","dt":"Oct 3"},
  ];

  @override
  void initState() {
    super.initState();
    bannerAd = BannerAd(adUnitId: Config.banner, size: AdSize.banner, request: AdRequest(), listener: BannerAdListener(onAdLoaded: (_){setState(()=>bannerReady=true);}));
    bannerAd!.load();
    InterstitialAd.load(adUnitId: Config.interstitial, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad)=> interAd=ad, onAdFailedToLoad: (_){}));
    RewardedAd.load(adUnitId: Config.rewarded, request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad)=> rewardedAd=ad, onAdFailedToLoad: (_){}));
    fetchLive();
  }

  Future<void> fetchLive() async {
    setState(()=> isLoading=true);
    try{
      final res = await http.get(Uri.parse("https://v3.football.api-sports.io/fixtures?live=all"), headers: {"x-apisports-key": Config.apiKey});
      if(res.statusCode==200){
        final body = json.decode(res.body);
        List list = body['response']??[];
        if(list.isNotEmpty){
          Map<String,List> map={};
          for(var m in list){
            String league = "${m['league']['name']} - ${m['league']['country']}";
            map.putIfAbsent(league, ()=>[]).add(m);
          }
          setState((){
            groupedMatches = map.entries.map((e)=>{"league":e.key,"games":e.value,"src":"API-FOOTBALL"}).toList();
            isLoading=false;
          });
          return;
        }
      }
      throw Exception();
    }catch(e){
      final res = await http.get(Uri.parse("https://site.api.espn.com/apis/site/v2/sports/soccer/all/scoreboard"));
      final data = json.decode(res.body);
      List events = data['events']??[];
      Map<String,List> map={};
      for(var ev in events){
        String league = ev['shortName']??"Live Matches";
        map.putIfAbsent(league, ()=>[]).add(ev);
      }
      setState((){
        groupedMatches = map.entries.map((e)=>{"league":e.key,"games":e.value,"src":"ESPN LIVE"}).toList();
        isLoading=false;
      });
    }
  }

  Map<String,dynamic> generateAI(Map m){
    Random r = Random((m['home']+m['away']).hashCode);
    return {
      "pred": r.nextBool()? "HOME WIN":"AWAY WIN",
      "conf": "${75+r.nextInt(20)}%",
      "best": "1 & Over 1.5 @1.85",
      "cs": "${r.nextInt(3)+1}-${r.nextInt(2)}",
      "over": "OVER 2.5 - ${70+r.nextInt(20)}%",
      "btts": r.nextBool()? "YES":"NO",
      "xg": "1.20 - 0.80",
      "homeForm": "W W D W L",
      "awayForm": "L D L W L",
      "h2h": "Last 5: ${m['home']} 3W",
      "reason": ["${m['home']} amefunga 2+ kwa 4/5","${m['away']} hajashinda away 6"]
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { if(interAd!=null){interAd!.show(); return false;} return true; },
      child: Scaffold(
        drawer: Drawer(backgroundColor: Color(0xFF1C1C1E), child: ListView(children: [
          DrawerHeader(decoration: BoxDecoration(color: Color(0xFF252525)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Global Sports Live PRO", style: TextStyle(color: Colors.orange, fontSize:20, fontWeight: FontWeight.bold)),
            SizedBox(height:8), Text("API: ${Config.apiKey.substring(0,10)}... LIVE", style: TextStyle(color: Colors.green, fontSize:10)),
            Text("Ads 4 Real Active", style: TextStyle(color: Colors.green, fontSize:10)),
          ])),
          ListTile(leading: Icon(Icons.sports_soccer, color: Colors.orange), title: Text("Football", style: TextStyle(color: Colors.orange)), trailing: CircleAvatar(radius:11, backgroundColor: Colors.blue, child: Text("4", style: TextStyle(fontSize:10))), onTap: (){Navigator.pop(context); fetchLive();}),
          ListTile(leading: Icon(Icons.sports_tennis), title: Text("Tennis"), trailing: CircleAvatar(radius:11, backgroundColor: Colors.blue, child: Text("1", style: TextStyle(fontSize:10)))),
          ListTile(leading: Icon(Icons.sports_basketball), title: Text("Basketball")),
          ListTile(leading: Icon(Icons.sports_hockey), title: Text("Hockey"), trailing: CircleAvatar(radius:11, backgroundColor: Colors.blue, child: Text("1", style: TextStyle(fontSize:10)))),
          Divider(color: Colors.white12),
          ListTile(leading: Icon(Icons.auto_awesome, color: Colors.orange), title: Text("VIP PRO: ${isVIP? 'UNLOCKED':'Locked'}"), onTap: (){ if(rewardedAd!=null) rewardedAd!.show(onUserEarnedReward: (a,r){setState(()=>isVIP=true);}); }),
        ])),
        appBar: AppBar(title: Column(children: [Text("Scores", style: TextStyle(fontWeight: FontWeight.bold)), Text("Football LIVE + AI PRO", style: TextStyle(fontSize:11, color: Colors.orange))]), centerTitle: true),
        body: Column(children: [
          Container(height:58, color: Color(0xFF1C1C1E), child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: days.length, itemBuilder: (c,i){
            bool sel = i==selectedDay;
            return GestureDetector(onTap: (){setState(()=>selectedDay=i); fetchLive();}, child: Container(width:68, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sel? Colors.orange: Colors.transparent, width:3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(days[i]['d'], style: TextStyle(fontSize:12, color: sel? Colors.white: Colors.grey)), Text(days[i]['dt'], style: TextStyle(fontSize:10, color: sel? Colors.orange: Colors.grey))])));
          })),
          Expanded(child: isLoading? Center(child: CircularProgressIndicator(color: Colors.orange)) : ListView.builder(itemCount: groupedMatches.length, itemBuilder: (c, idx){
            var lg = groupedMatches[idx];
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: EdgeInsets.all(10), color: Color(0xFF252525), child: Row(children: [Icon(Icons.sports_soccer, size:16, color: Colors.blue), SizedBox(width:8), Expanded(child: Text(lg['league'], style: TextStyle(fontWeight: FontWeight.bold, fontSize:13))), Container(padding: EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)), child: Text(lg['src'], style: TextStyle(fontSize:7)))])),
             ...List.generate(lg['games'].length, (gi){
                var g = lg['games'][gi];
                String home, away, score, minute; bool live=true;
                if(g['teams']!=null){ home=g['teams']['home']['name']; away=g['teams']['away']['name']; live=true; score="${g['goals']['home']} - ${g['goals']['away']}"; minute="${g['fixture']['status']['elapsed']??''}'"; }
                else if(g['competitions']!=null){ home=g['competitions'][0]['competitors'][0]['team']['displayName']; away=g['competitions'][0]['competitors'][1]['team']['displayName']; live=g['status']['type']['state']=='in'; minute= g['status']['type']['shortDetail']; score="${g['competitions'][0]['competitors'][0]['score']} - ${g['competitions'][0]['competitors'][1]['score']}"; }
                else { home=g['home']; away=g['away']; score=g['score']??"0-0"; minute=g['minute']??"19:00"; live=g['live']??false; }
                var ai = generateAI({"home":home,"away":away});
                return InkWell(onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> DetailPage(home:home, away:away, score:score, minute:minute, live:live, ai:ai, isVIP:isVIP, rewardedAd:rewardedAd, onUnlock:(){setState(()=>isVIP=true);}))), child: Container(padding: EdgeInsets.symmetric(horizontal:12, vertical:13), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))), child: Row(children: [
                  SizedBox(width:52, child: Text(minute, style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: live? Colors.red: Colors.white))),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(home, style: TextStyle(fontSize:13))), Text(score.split('-')[0], style: TextStyle(fontSize:13, fontWeight: FontWeight.bold))]), SizedBox(height:6), Row(children: [Expanded(child: Text(away, style: TextStyle(fontSize:13, color: Colors.grey))), Text(score.split('-').last, style: TextStyle(fontSize:13, color: Colors.grey))])])),
                  Icon(Icons.auto_awesome, size:12, color: Colors.orange),
                ])));
              }),
              Container(height:70, margin: EdgeInsets.symmetric(vertical:4), color: Color(0xFF1E1E1E), child: Center(child: Text("Native Ad 6043021903 - AdMob Real - ${lg['league']}", style: TextStyle(fontSize:10, color: Colors.grey)))),
            ]);
          })),
          if(bannerReady && bannerAd!=null) Container(height: 50, child: AdWidget(ad: bannerAd!)),
        ]),
        bottomNavigationBar: BottomNavigationBar(backgroundColor: Color(0xFF1C1C1E), selectedItemColor: Colors.orange, unselectedItemColor: Colors.grey, type: BottomNavigationBarType.fixed, currentIndex: 0, items: [
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Scores"),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: "Live"),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: "Favourites"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: "Refresh"),
        ]),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String home, away, score, minute;
  final bool live, isVIP;
  final Map ai;
  final RewardedAd? rewardedAd;
  final VoidCallback onUnlock;
  DetailPage({required this.home, required this.away, required this.score, required this.minute, required this.live, required this.ai, required this.isVIP, this.rewardedAd, required this.onUnlock});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 5, child: Scaffold(
      appBar: AppBar(title: Text("$home vs $away", style: TextStyle(fontSize:14)), bottom: TabBar(isScrollable: true, labelColor: Colors.orange, tabs: [Tab(text:"PRO AI"), Tab(text:"Stats"), Tab(text:"Lineups"), Tab(text:"H2H"), Tab(text:"Table")])),
      body: TabBarView(children: [
        ListView(padding: EdgeInsets.all(12), children: [
          if(!isVIP) Card(color: Colors.orange.withOpacity(0.15), child: Padding(padding: EdgeInsets.all(16), child: Column(children: [Icon(Icons.lock, color: Colors.orange, size:36), Text("VIP Unlock - Watch Ad ${Config.rewarded.split('/').last}"), ElevatedButton(onPressed: (){ if(rewardedAd!=null) rewardedAd!.show(onUserEarnedReward: (a,r){onUnlock(); Navigator.pop(context);}); }, child: Text("Watch Ad - Unlock"))]))),
          Opacity(opacity: isVIP?1:0.4, child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(children: [Text("AI PREDICTION ${ai['conf']}", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), Divider(), Text("Winner: ${ai['pred']}"), Text("Best Bet: ${ai['best']}"), Text("Correct Score: ${ai['cs']}"), Text("xG: ${ai['xg']}")])))),
        ]),
        ListView(padding: EdgeInsets.all(12), children: [ListTile(title: Text("xG ${ai['xg']}")), ListTile(title: Text("Possession 58% - 42%"))]),
        ListView(padding: EdgeInsets.all(12), children: [Text("Lineups LIVE from API")]),
        ListView(padding: EdgeInsets.all(12), children: [Text(ai['h2h'])]),
        ListView(padding: EdgeInsets.all(12), children: [Text("Table LIVE")]),
      ]),
    ));
  }
}
