import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(GlobalSportsLiveApp());
}

class GlobalSportsLiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Sports Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, scaffoldBackgroundColor: Color(0xFF0F172A)),
      home: HomeScreen(),
    );
  }
}

class LiveMatch {
  String sport, league, homeTeam, awayTeam, homeScore, awayScore, time, country;
  bool isLive;
  LiveMatch({required this.sport, required this.league, required this.homeTeam, required this.awayTeam, required this.homeScore, required this.awayScore, required this.time, required this.country, this.isLive = true});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedSport = "All";
  List<String> sports = ["All", "Football", "NBA", "Tennis", "Hockey", "Cricket"];
  late List<LiveMatch> allMatches;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    allMatches = getAllMatches();
    // Update LIVE kila sekunde 5
    timer = Timer.periodic(Duration(seconds: 5), (t) {
      setState(() {
        allMatches = getAllMatches();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  List<LiveMatch> getAllMatches() {
    return [
      LiveMatch(sport: "Football", league: "NBC Premier League 🇹🇿", homeTeam: "Yanga SC", awayTeam: "Simba SC", homeScore: "2", awayScore: "1", time: "78'", country: "TZ"),
      LiveMatch(sport: "Football", league: "Premier League 🏴󠁧󠁢󠁥󠁮󠁧󠁿", homeTeam: "Man City", awayTeam: "Arsenal", homeScore: "1", awayScore: "1", time: "65'", country: "ENG"),
      LiveMatch(sport: "Football", league: "La Liga 🇪🇸", homeTeam: "Real Madrid", awayTeam: "Barcelona", homeScore: "3", awayScore: "2", time: "89'", country: "ESP"),
      LiveMatch(sport: "Football", league: "Serie A 🇮🇹", homeTeam: "Inter", awayTeam: "AC Milan", homeScore: "0", awayScore: "0", time: "12'", country: "ITA"),
      LiveMatch(sport: "Football", league: "Bundesliga 🇩🇪", homeTeam: "Bayern", awayTeam: "Dortmund", homeScore: "2", awayScore: "2", time: "54'", country: "GER"),
      LiveMatch(sport: "NBA", league: "NBA 🇺🇸", homeTeam: "Lakers", awayTeam: "Warriors", homeScore: "102", awayScore: "98", time: "Q4 2:34", country: "USA"),
      LiveMatch(sport: "NBA", league: "NBA 🇺🇸", homeTeam: "Bulls", awayTeam: "Heat", homeScore: "89", awayScore: "91", time: "Q3 5:12", country: "USA"),
      LiveMatch(sport: "Tennis", league: "Wimbledon 🇬🇧", homeTeam: "Djokovic", awayTeam: "Alcaraz", homeScore: "6", awayScore: "4", time: "Set 2", country: "UK"),
      LiveMatch(sport: "Hockey", league: "NHL 🇨🇦", homeTeam: "Maple Leafs", awayTeam: "Canadiens", homeScore: "3", awayScore: "2", time: "P3 10:20", country: "CAN"),
      LiveMatch(sport: "Cricket", league: "IPL 🇮🇳", homeTeam: "Mumbai Indians", awayTeam: "Chennai Super", homeScore: "156/4", awayScore: "120/3", time: "15.3 Ov", country: "IND"),
      LiveMatch(sport: "Cricket", league: "T20 World Cup 🌍", homeTeam: "Tanzania", awayTeam: "Kenya", homeScore: "89/2", awayScore: "78/5", time: "12.1 Ov", country: "TZ"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var filtered = selectedSport == "All"? allMatches : allMatches.where((m) => m.sport == selectedSport).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("GLOBAL SPORTS LIVE 🌍", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1E293B),
        centerTitle: true,
        actions: [Padding(padding: EdgeInsets.all(8), child: Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.circle, size: 10, color: Colors.white), SizedBox(width: 4), Text("LIVE", style: TextStyle(fontWeight: FontWeight.bold))])))]
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            color: Color(0xFF1E293B),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sports.length,
              itemBuilder: (ctx, i) {
                bool isSelected = sports[i] == selectedSport;
                return GestureDetector(
                  onTap: () => setState(() => selectedSport = sports[i]),
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: isSelected? Colors.green : Color(0xFF334155), borderRadius: BorderRadius.circular(20)),
                    child: Center(child: Text(sports[i], style: TextStyle(color: Colors.white, fontWeight: isSelected? FontWeight.bold : FontWeight.normal))),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                var m = filtered[i];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: Color(0xFF1E293B),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green, child: Text(m.sport[0], style: TextStyle(color: Colors.white))),
                    title: Text("${m.homeTeam} vs ${m.awayTeam}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${m.league} • ${m.time}", style: TextStyle(color: Colors.grey)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${m.homeScore} - ${m.awayScore}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 2),
                        Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
