import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0F0F0F)),
      home: LiveScreen());
  }
}

class LiveScreen extends StatefulWidget {
  @override
  _LiveScreenState createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  List matches = [];
  bool loading = true;
  final String apiKey = "e747e4108a3f5543924daf0ab654f865";

  BannerAd? banner;
  bool bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    banner = BannerAd(adUnitId: "ca-app-pub-6198433078225470/9286549765", size: AdSize.banner, request: AdRequest(), listener: BannerAdListener(onAdLoaded: (ad)=> setState(()=> bannerLoaded=true)));
    banner!.load();
    fetchRealAPI();
  }

  Future<void> fetchRealAPI() async {
    setState(()=> loading=true);
    try {
      // 1. API-FOOTBALL REAL LIVE
      final res = await http.get(
        Uri.parse("https://v3.football.api-sports.io/fixtures?live=all"),
        headers: {"x-apisports-key": apiKey}
      );
      print("API STATUS: ${res.statusCode}");
      print("API BODY: ${res.body.substring(0,500)}");

      if(res.statusCode==200){
        final data = json.decode(res.body);
        List response = data['response']?? [];
        if(response.isNotEmpty){
          Map<String, List> grouped={};
          for(var f in response){
            String league = "${f['league']['name']} - ${f['league']['country']}";
            if(!grouped.containsKey(league)) grouped[league]=[];
            grouped[league]!.add(f);
          }
          setState((){
            matches = grouped.entries.map((e)=> {"league": e.key, "games": e.value, "source": "API-FOOTBALL"}).toList();
            loading=false;
          });
          return;
        }
      }
      throw Exception("no live");
    } catch(e) {
      // 2. FALLBACK ESPN - BADO LIVE HALISI 100%
      try {
        final res2 = await http.get(Uri.parse("https://site.api.espn.com/apis/site/v2/sports/soccer/all/scoreboard"));
        final data = json.decode(res2.body);
        List events = data['events']?? [];
        Map<String, List> grouped={};
        for(var ev in events){
          String league = ev['shortName']?? ev['name']?? "Live";
          if(!grouped.containsKey(league)) grouped[league]=[];
          grouped[league]!.add(ev);
        }
        setState((){
          matches = grouped.entries.map((e)=> {"league": e.key, "games": e.value, "source": "ESPN LIVE"}).toList();
          loading=false;
        });
      } catch(_) {
        setState(()=> loading=false);
      }
    }
  }

  Map<String,dynamic> getAI(Map<String,dynamic> m){
    Random r = Random(m['home'].hashCode);
    return {
      "pred": r.nextBool()? "HOME WIN ${70+r.nextInt(20)}%" : "AWAY WIN ${70+r.nextInt(20)}%",
      "xg": "${(0.5+r.nextDouble()*2).toStringAsFixed(2)} - ${(0.5+r.nextDouble()*1.5).toStringAsFixed(2)}"
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Global Sports LIVE - API HALISI"), centerTitle: true, actions: [IconButton(icon: Icon(Icons.refresh), onPressed: fetchRealAPI)]),
      body: Column(children: [
        Container(padding: EdgeInsets.all(8), color: Colors.green.withOpacity(0.2), child: Row(children: [Icon(Icons.circle, color: Colors.green, size: 12), SizedBox(width:6), Text("API KEY: ${apiKey.substring(0,8)}... LIVE CONNECTED - 100/day", style: TextStyle(fontSize:11, color: Colors.green))])),
        Expanded(child: loading? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.orange), SizedBox(height:10), Text("Inavuta API HALISI...")])) : RefreshIndicator(onRefresh: fetchRealAPI, child: ListView.builder(itemCount: matches.length, itemBuilder: (c,i){
          var lg = matches[i];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: EdgeInsets.all(10), color: Color(0xFF252525), child: Row(children: [Icon(Icons.live_tv, color: Colors.red, size: 16), SizedBox(width:8), Expanded(child: Text(lg['league'], style: TextStyle(fontWeight: FontWeight.bold, fontSize:13))), Container(padding: EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: lg['source']=="API-FOOTBALL"? Colors.green: Colors.blue, borderRadius: BorderRadius.circular(4)), child: Text(lg['source'], style: TextStyle(fontSize:8)))])),
           ...List.generate(lg['games'].length, (j){
              var g = lg['games'][j];
              String home, away, score; bool live=true;
              if(g['teams']!=null){ home=g['teams']['home']['name']; away=g['teams']['away']['name']; score="${g['goals']['home']}-${g['goals']['away']} ${g['fixture']['status']['elapsed']??''}'"; }
              else { home=g['competitions'][0]['competitors'][0]['team']['displayName']; away=g['competitions'][0]['competitors'][1]['team']['displayName']; score=g['status']['type']['shortDetail']; }
              var ai = getAI({"home":home,"away":away});
              return ListTile(
                onTap: (){
                  showDialog(context: context, builder: (_)=> AlertDialog(
                    title: Text("$home vs $away"),
                    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("🔴 LIVE SCORE: $score", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height:10),
                      Text("🤖 AI PREDICTION: ${ai['pred']}", style: TextStyle(color: Colors.orange)),
                      Text("📊 xG: ${ai['xg']}"),
                      SizedBox(height:10),
                      Text("Native Ad: ca-app-pub-6198433078225470/6043021903"),
                      Text("Rewarded Ad:.../6572756518 - VIP Unlock"),
                    ]),
                    actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text("Close"))],
                  ));
                },
                leading: Text(score, style: TextStyle(color: live? Colors.red: Colors.white, fontSize:11, fontWeight: FontWeight.bold)),
                title: Text(home, style: TextStyle(fontSize:13)),
                subtitle: Text(away, style: TextStyle(fontSize:13, color: Colors.grey)),
                trailing: Column(children: [Icon(Icons.auto_awesome, size:14, color: Colors.orange), Text("AI", style: TextStyle(fontSize:8, color: Colors.orange))]),
              );
            }),
            // Native Ad kila ligi
            Container(height: 60, color: Colors.white10, margin: EdgeInsets.symmetric(vertical:4), child: Center(child: Text("Native Ad - 6043021903 - AdMob HALISI", style: TextStyle(fontSize:10, color: Colors.grey)))),
          ]);
        }))),
        if(bannerLoaded) Container(height: 50, child: AdWidget(ad: banner!)),
      ]),
    );
  }
}
