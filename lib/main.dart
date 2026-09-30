                                                                                                          @override
 import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fl_chart/fl_chart.dart';

const String APP_NAME = "Global Sports Live";
const String OWNER_ID = "GS-LIVE-38-WORLDWIDE-AI";
const String API_KEY = "e747e4108a3f5543924daf0ab654f865";
const String BASE_URL = "https://v3.football.api-sports.io";
const String BANNER_ID = "ca-app-pub-6198433078225470/9286549765";
const String INTERSTITIAL_ID = "ca-app-pub-6198433078225470/1655471753";
const String NATIVE_ID = "ca-app-pub-6198433078225470/6043021903";
const String REWARDED_ID = "ca-app-pub-6198433078225470/6572756518";

const Color PRIMARY_GREEN = Color(0xFF00C853);
const Color BG_DARK = Color(0xFF0A0E1A);
const Color CARD_DARK = Color(0xFF151A2B);

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const GlobalSportsApp());
}
class GlobalSportsApp extends StatelessWidget{
  const GlobalSportsApp({super.key});
  @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,home:const HomeScreen());
}

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});
  @override State<HomeScreen> createState()=>_HomeState();
}
class _HomeState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  late TabController tab;
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;

  final List<Map<String,dynamic>> leagues = [
    // FOOTBALL - FLAG ZOTE SAFI, ZINAONEKANA!
    {"id":"EPL-001","league":"\u{1F1EC}\u{1F1E7} Premier League","home":"Arsenal","away":"Man City","score":"2-1","min":"78'","sport":"Football"},
    {"id":"LALIGA-002","league":"\u{1F1EA}\u{1F1F8} LaLiga","home":"Real Madrid","away":"Barca","score":"1-0","min":"62'","sport":"Football"},
    {"id":"BUND-003","league":"\u{1F1E9}\u{1F1EA} Bundesliga","home":"Bayern","away":"Dortmund","score":"3-2","min":"85'","sport":"Football"},
    {"id":"SERIE-004","league":"\u{1F1EE}\u{1F1F9} Serie A","home":"Inter","away":"Milan","score":"0-0","min":"15'","sport":"Football"},
    {"id":"LIGUE-005","league":"\u{1F1EB}\u{1F1F7} Ligue 1","home":"PSG","away":"Marseille","score":"2-2","min":"HT","sport":"Football"},
    {"id":"ERED-006","league":"\u{1F1F3}\u{1F1F1} Eredivisie","home":"Ajax","away":"PSV","score":"1-1","min":"34'","sport":"Football"},
    {"id":"PRIM-007","league":"\u{1F1F5}\u{1F1F9} Primeira Liga","home":"Benfica","away":"Porto","score":"2-0","min":"52'","sport":"Football"},
    {"id":"MLS-008","league":"\u{1F1FA}\u{1F1F8} MLS","home":"Inter Miami","away":"LA Galaxy","score":"3-1","min":"70'","sport":"Football"},
    {"id":"SAUDI-009","league":"\u{1F1F8}\u{1F1E6} Saudi Pro","home":"Al Nassr","away":"Al Hilal","score":"1-2","min":"88'","sport":"Football"},
    {"id":"ARGEN-010","league":"\u{1F1E6}\u{1F1F7} Argentina","home":"River","away":"Boca","score":"0-0","min":"20'","sport":"Football"},
    {"id":"BRAZ-011","league":"\u{1F1E7}\u{1F1F7} Brazil Serie A","home":"Flamengo","away":"Palmeiras","score":"2-2","min":"65'","sport":"Football"},
    {"id":"TURK-012","league":"\u{1F1F9}\u{1F1F7} Super Lig","home":"Galatasaray","away":"Fenerbahce","score":"1-0","min":"45'","sport":"Football"},
    {"id":"BELG-013","league":"\u{1F1E7}\u{1F1EA} Pro League","home":"Club Brugge","away":"Anderlecht","score":"0-1","min":"30'","sport":"Football"},
    {"id":"SCOT-014","league":"\u{1F1EC}\u{1F1E7} Scottish Prem","home":"Celtic","away":"Rangers","score":"2-1","min":"77'","sport":"Football"},
    {"id":"CHAMP-015","league":"\u{1F1EC}\u{1F1E7} Championship","home":"Leeds","away":"Leicester","score":"1-1","min":"60'","sport":"Football"},
    {"id":"UCL-016","league":"\u{1F1EA}\u{1F1FA} Champions League","home":"Man Utd","away":"Juventus","score":"1-1","min":"55'","sport":"Football"},
    {"id":"UEL-017","league":"\u{1F1EA}\u{1F1FA} Europa League","home":"Liverpool","away":"Roma","score":"2-0","min":"40'","sport":"Football"},
    {"id":"AFCON-018","league":"\u{1F30D} AFCON","home":"Tanzania","away":"Morocco","score":"0-1","min":"42'","sport":"Football"},
    {"id":"LIB-019","league":"\u{1F30E} Libertadores","home":"Fluminense","away":"Boca","score":"1-0","min":"90'","sport":"Football"},
    {"id":"JLEAG-020","league":"\u{1F1EF}\u{1F1F5} J-League","home":"Kashima","away":"Yokohama","score":"1-2","min":"68'","sport":"Football"},
    {"id":"NBA-101","league":"\u{1F1FA}\u{1F1F8} NBA","home":"Lakers","away":"Warriors","score":"102-98","min":"Q4","sport":"Basketball"},
    {"id":"EURO-102","league":"\u{1F1EA}\u{1F1FA} EuroLeague","home":"Real Madrid B","away":"Barca B","score":"76-74","min":"Q4","sport":"Basketball"},
    {"id":"WNBA-103","league":"\u{1F1FA}\u{1F1F8} WNBA","home":"Liberty","away":"Aces","score":"82-80","min":"Q4","sport":"Basketball"},
    {"id":"CBA-104","league":"\u{1F1E8}\u{1F1F3} CBA China","home":"Guangdong","away":"Liaoning","score":"95-92","min":"Q3","sport":"Basketball"},
    {"id":"NBL-105","league":"\u{1F1E6}\u{1F1FA} NBL Australia","home":"Sydney Kings","away":"Perth Wildcats","score":"88-85","min":"Q4","sport":"Basketball"},
    {"id":"IPL-201","league":"\u{1F1EE}\u{1F1F3} IPL","home":"Mumbai","away":"CSK","score":"187/4","min":"18.2ov","sport":"Cricket"},
    {"id":"BBL-202","league":"\u{1F1E6}\u{1F1FA} Big Bash","home":"Sydney Sixers","away":"Perth Scorchers","score":"156/6","min":"16ov","sport":"Cricket"},
    {"id":"PSL-203","league":"\u{1F1F5}\u{1F1F0} PSL","home":"Lahore","away":"Karachi","score":"142/3","min":"14ov","sport":"Cricket"},
    {"id":"WIM-301","league":"\u{1F3BE} Wimbledon","home":"Alcaraz","away":"Djokovic","score":"2-1","min":"Set4","sport":"Tennis"},
    {"id":"USO-302","league":"\u{1F3BE} US Open","home":"Sinner","away":"Medvedev","score":"1-1","min":"Set3","sport":"Tennis"},
    {"id":"VOL-401","league":"\u{1F3D0} Nations League Volleyball","home":"Brazil","away":"Poland","score":"2-1","min":"Set4","sport":"Volleyball","sets":"25-22,18-25,25-20"},
    {"id":"VOL-402","league":"\u{1F3D0} CEV Champions Volleyball","home":"Trentino","away":"Zaksa","score":"0-2","min":"Set3","sport":"Volleyball","sets":"23-25,21-25"},
    {"id":"VOL-403","league":"\u{1F3D0} African Champ Volleyball","home":"Tanzania","away":"Egypt","score":"2-0","min":"Set3","sport":"Volleyball","sets":"25-18,25-20"},
    {"id":"MLB-501","league":"\u{26BE} MLB Baseball","home":"Yankees","away":"Dodgers","score":"5-3","min":"7th Inn","sport":"Baseball","innings":"5-3"},
    {"id":"NPB-502","league":"\u{26BE} NPB Baseball","home":"Giants","away":"Tigers","score":"2-2","min":"8th Inn","sport":"Baseball","innings":"2-2"},
    {"id":"KBO-503","league":"\u{26BE} KBO Baseball","home":"LG Twins","away":"Doosan","score":"4-1","min":"6th Inn","sport":"Baseball","innings":"4-1"},
    {"id":"F1-601","league":"\u{1F3C1} Formula-1","home":"Verstappen","away":"Hamilton","score":"Lap 42/58","min":"Live","sport":"Racing"},
    {"id":"MOTO-602","league":"\u{1F3CD} MotoGP","home":"Bagnaia","away":"Martin","score":"Lap 18","min":"Live","sport":"Racing"},
  ];

  @override void initState(){
    super.initState();
    tab=TabController(length:8,vsync:this);
    loadAds();
  }
  void loadAds(){
    bannerAd=BannerAd(adUnitId:BANNER_ID,size:AdSize.banner,request:const AdRequest(),listener:BannerAdListener(onAdFailedToLoad:(ad,err)=>ad.dispose()))..load();
    InterstitialAd.load(adUnitId:INTERSTITIAL_ID,request:const AdRequest(),adLoadCallback:InterstitialAdLoadCallback(onAdLoaded:(ad)=>interstitialAd=ad,onAdFailedToLoad:(e){}));
  }

  @override Widget build(BuildContext c){
    return Scaffold(
      backgroundColor:BG_DARK,
      appBar:AppBar(backgroundColor:BG_DARK,title:const Text('GLOBAL SPORTS LIVE - 38 LEAGUES - FLAG VISIBLE',style:TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.bold)),bottom:TabBar(controller:tab,isScrollable:true,indicatorColor:PRIMARY_GREEN,labelColor:PRIMARY_GREEN,unselectedLabelColor:Colors.white54,labelStyle:const TextStyle(fontSize:10),tabs:const[Tab(text:'ALL 38'),Tab(text:'FOOT'),Tab(text:'BASKET'),Tab(text:'CRICKET'),Tab(text:'TENNIS'),Tab(text:'VOLLEY'),Tab(text:'BASEBALL'),Tab(text:'F1')])),
      bottomNavigationBar:bannerAd==null?null:Container(height:50,child:AdWidget(ad:bannerAd!)),
      body:TabBarView(controller:tab,children:[
        buildList(leagues),
        buildList(leagues.where((m)=>m['sport']=='Football').toList()),
        buildList(leagues.where((m)=>m['sport']=='Basketball').toList()),
        buildList(leagues.where((m)=>m['sport']=='Cricket').toList()),
        buildList(leagues.where((m)=>m['sport']=='Tennis').toList()),
        buildList(leagues.where((m)=>m['sport']=='Volleyball').toList()),
        buildList(leagues.where((m)=>m['sport']=='Baseball').toList()),
        buildList(leagues.where((m)=>m['sport']=='Racing').toList()),
      ]),
    );
  }

  Widget buildList(List list){
    return ListView.builder(padding:const EdgeInsets.all(12),itemCount:list.length,itemBuilder:(_,i){
      final m=list[i];
      return GestureDetector(
        onTap:(){if(interstitialAd!=null)interstitialAd!.show(); Navigator.push(context,MaterialPageRoute(builder:(_)=>AnalysisScreen(match:m)));},
        child:Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:CARD_DARK,borderRadius:BorderRadius.circular(12)),child:Column(children:[
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Expanded(child:Text(m['league'],style:TextStyle(color:PRIMARY_GREEN,fontSize:9,fontWeight:FontWeight.bold))),Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),decoration:BoxDecoration(color:Colors.red,borderRadius:BorderRadius.circular(4)),child:Text('LIVE ${m['min']}',style:const TextStyle(color:Colors.white,fontSize:8)))]),
          const SizedBox(height:10),
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Expanded(child:Text(m['home'],style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),decoration:BoxDecoration(color:BG_DARK,borderRadius:BorderRadius.circular(6)),child:Text(m['score'],style:const TextStyle(color:PRIMARY_GREEN,fontWeight:FontWeight.bold))),Expanded(child:Text(m['away'],textAlign:TextAlign.right,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)))]),
        ])),
      );
    });
  }
}

class AnalysisScreen extends StatefulWidget{
  final Map match;
  const AnalysisScreen({super.key,required this.match});
  @override State<AnalysisScreen> createState()=>_AState();
}
class _AState extends State<AnalysisScreen>{
  String pred="AI Analyzing..."; String conf="0%"; String tip="Connecting AI..."; bool load=true; RewardedAd? rew;
  @override void initState(){
    super.initState();
    RewardedAd.load(adUnitId:REWARDED_ID,request:const AdRequest(),rewardedAdLoadCallback:RewardedAdLoadCallback(onAdLoaded:(ad)=>rew=ad,onAdFailedToLoad:(e){}));
    Future.delayed(const Duration(seconds:2),(){
      setState((){
        final r=DateTime.now().millisecond%3;
        if(r==0){pred="${widget.match['home']} WIN"; conf="78%"; tip="AI: 62% poss, xG 1.84";}
        else if(r==1){pred="DRAW"; conf="65%"; tip="AI: Defensive, Under 2.5";}
        else{pred="${widget.match['away']} WIN"; conf="71%"; tip="AI: Counter attack strong";}
        load=false;
      });
    });
  }
  @override Widget build(BuildContext c){
    return Scaffold(backgroundColor:BG_DARK,appBar:AppBar(backgroundColor:BG_DARK,title:Text('${widget.match['home']} vs ${widget.match['away']}',style:const TextStyle(fontSize:12))),body:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
      Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:CARD_DARK,borderRadius:BorderRadius.circular(12)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[Text(widget.match['home'],style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),Text(widget.match['score'],style:const TextStyle(color:PRIMARY_GREEN,fontSize:24,fontWeight:FontWeight.bold)),Text(widget.match['away'],style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))])),
      const SizedBox(height:12),
      Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.purple.withOpacity(0.15),borderRadius:BorderRadius.circular(12),border:Border.all(color:Colors.purple)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Icon(Icons.smart_toy,color:Colors.purple,size:16),const SizedBox(width:6),Text('AI ENGINE - ${widget.match['id']}',style:const TextStyle(color:Colors.purple,fontSize:10,fontWeight:FontWeight.bold))]),const SizedBox(height:10),load?const CircularProgressIndicator(color:Colors.purple):Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(pred,style:const TextStyle(color:Colors.white,fontSize:15,fontWeight:FontWeight.bold)),Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:Colors.purple,borderRadius:BorderRadius.circular(6)),child:Text(conf,style:const TextStyle(color:Colors.white,fontSize:11)))]),Text(tip,style:const TextStyle(color:Colors.white70,fontSize:11))])])),
      const SizedBox(height:12),
      Container(height:140,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:CARD_DARK,borderRadius:BorderRadius.circular(12)),child:LineChart(LineChartData(gridData:const FlGridData(show:false),titlesData:const FlTitlesData(show:false),borderData:FlBorderData(show:false),lineBarsData:[LineChartBarData(spots:const[FlSpot(0,1),FlSpot(1,3),FlSpot(2,2),FlSpot(3,4.5),FlSpot(5,6)],isCurved:true,color:PRIMARY_GREEN,barWidth:3,dotData:const FlDotData(show:false),belowBarData:BarAreaData(show:true,color:PRIMARY_GREEN.withOpacity(0.15)))]])),
      const SizedBox(height:12),
      SizedBox(width:double.infinity,child:ElevatedButton.icon(icon:const Icon(Icons.lock_open,size:16),label:const Text("VIP Unlock - Watch Ad",style:TextStyle(fontSize:11)),style:ElevatedButton.styleFrom(backgroundColor:Colors.orange),onPressed:(){if(rew!=null)rew!.show(onUserEarnedReward:(a,r){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("VIP Unlocked!")));});})),
    ])));
  }
}                                                                                                                                                                                                                                                                                                                           Widget build(BuildContext context){
                                                                                                                                                                                                                                                                                                                                return Scaffold(
                                                                                                                                                                                                                                                                                                                                      backgroundColor:const Color(0xFF0A0E1A),
                                                                                                                                                                                                                                                                                                                                            appBar:AppBar(backgroundColor:const Color(0xFF0A0E1A),title:Text('${match['home']} vs ${match['away']}',style:const TextStyle(fontSize:13))),
                                                                                                                                                                                                                                                                                                                                                  body:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(children:[
                                                                                                                                                                                                                                                                                                                                                          Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFF151A2B),borderRadius:BorderRadius.circular(12)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[Text(match['home'],style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),Text(match['score'],style:const TextStyle(color:Color(0xFF00C853),fontSize:24,fontWeight:FontWeight.bold)),Text(match['away'],style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))])),
                                                                                                                                                                                                                                                                                                                                                                  const SizedBox(height:12),
                                                                                                                                                                                                                                                                                                                                                                          Container(height:180,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFF151A2B),borderRadius:BorderRadius.circular(12)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Attack Momentum',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),const SizedBox(height:15),Expanded(child:LineChart(LineChartData(gridData:const FlGridData(show:false),titlesData:const FlTitlesData(show:false),borderData:FlBorderData(show:false),lineBarsData:[LineChartBarData(spots:const[FlSpot(0,1),FlSpot(1,3),FlSpot(2,2),FlSpot(3,4),FlSpot(4,3),FlSpot(5,5)],isCurved:true,color:const Color(0xFF00C853),barWidth:3,dotData:const FlDotData(show:false))])))])),
                                                                                                                                                                                                                                                                                                                                                                                  const SizedBox(height:12),
                                                                                                                                                                                                                                                                                                                                                                                          Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF151A2B),borderRadius:BorderRadius.circular(12)),child:Column(children:[row('xG','1.84','0.72'),row('Possession','62%','38%'),row('Shots','7','3'),row('Corners','8','2')])),
                                                                                                                                                                                                                                                                                                                                                                                                ])),
                                                                                                                                                                                                                                                                                                                                                                                                    );
                                                                                                                                                                                                                                                                                                                                                                                                      }
                                                                                                                                                                                                                                                                                                                                                                                                        Widget row(String l,String h,String a)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(h,style:const TextStyle(color:Colors.white)),Text(l,style:const TextStyle(color:Colors.white54,fontSize:11)),Text(a,style:const TextStyle(color:Colors.white))]));
                                                                                                                                                                                                                                                                                                                                                                                                        }
