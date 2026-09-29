import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(GlobalSportsLiveApp());

class GlobalSportsLiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Sports Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0A4A7A),
        scaffoldBackgroundColor: Color(0xFF001F3F),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF0A4A7A), centerTitle: true),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final pages = [FootballLiveFull(), NBALiveFull(), TennisLiveFull(), HockeyLiveFull(), CricketLiveFull()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Column(children: [Text('Global Sports Live'), Text('Score & Match Analysis', style: TextStyle(fontSize: 11, color: Color(0xFF00E5FF))) ])),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF001F3F),
        selectedItemColor: Color(0xFF00E5FF),
        unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Football'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_basketball), label: 'NBA'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'Tennis'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_hockey), label: 'Hockey'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_cricket), label: 'Cricket'),
        ],
      ),
    );
  }
}

// ================= FOOTBALL - FREE API =================
class FootballLiveFull extends StatefulWidget { @override _FootballLiveFullState createState() => _FootballLiveFullState(); }
class _FootballLiveFullState extends State<FootballLiveFull> {
  List matches = [];
  bool loading = true;

  @override
  void initState() { super.initState(); fetchLive(); }

  fetchLive() async {
    try {
      // API ya bure - ESPN (hakuna key inahitajika)
      var res = await http.get(Uri.parse('https://site.api.espn.com/apis/site/v2/sports/soccer/eng.1/scoreboard'));
      var data = json.decode(res.body);
      setState(() { matches = data['events']?? []; loading = false; });
    } catch (e) { setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
    if (matches.isEmpty) return Center(child: Text('No Live Matches Now - Check Later', style: TextStyle(color: Colors.white)));
    return RefreshIndicator(
      onRefresh: () async => fetchLive(),
      child: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (c, i) {
          var m = matches[i];
          var home = m['competitions'][0]['competitors'][0];
          var away = m['competitions'][0]['competitors'][1];
          var status = m['status']['type']['shortDetail'];
          return Card(
            color: Color(0xFF0A2A4A),
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('${home['team']['displayName']} ${home['score']} - ${away['score']} ${away['team']['displayName']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(status, style: TextStyle(color: Color(0xFF00E5FF))),
              trailing: Icon(Icons.live_tv, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}

// ================= OTHER SPORTS (Same logic) =================
class NBALiveFull extends StatelessWidget { @override Widget build(BuildContext c) => LiveTemplate(league: 'NBA', apiUrl: 'https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard', icon: '🏀'); }
class TennisLiveFull extends StatelessWidget { @override Widget build(BuildContext c) => LiveTemplate(league: 'ATP Tennis', apiUrl: 'https://site.api.espn.com/apis/site/v2/sports/tennis/atp/scoreboard', icon: '🎾'); }
class HockeyLiveFull extends StatelessWidget { @override Widget build(BuildContext c) => LiveTemplate(league: 'NHL', apiUrl: 'https://site.api.espn.com/apis/site/v2/sports/hockey/nhl/scoreboard', icon: '🏒'); }
class CricketLiveFull extends StatelessWidget { @override Widget build(BuildContext c) => LiveTemplate(league: 'Cricket', apiUrl: 'https://site.api.espn.com/apis/site/v2/sports/cricket/scoreboard', icon: '🏏'); }

class LiveTemplate extends StatefulWidget {
  final String league, apiUrl, icon;
  LiveTemplate({required this.league, required this.apiUrl, required this.icon});
  @override _LiveTemplateState createState() => _LiveTemplateState();
}
class _LiveTemplateState extends State<LiveTemplate> {
  List matches = []; bool loading = true;
  @override void initState() { super.initState(); fetchData(); }
  fetchData() async {
    try { var res = await http.get(Uri.parse(widget.apiUrl)); var data = json.decode(res.body); setState(() { matches = data['events']?? []; loading = false; }); } catch (e) { setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
    if (matches.isEmpty) return Center(child: Text('${widget.icon} No Live ${widget.league} Now', style: TextStyle(color: Colors.white)));
    return ListView.builder(itemCount: matches.length, itemBuilder: (c,i){
      var m = matches[i]; return Card(color: Color(0xFF0A2A4A), margin: EdgeInsets.all(8), child: ListTile(title: Text(m['name']?? '${widget.league} Match', style: TextStyle(color: Colors.white)), subtitle: Text(m['status']['type']['shortDetail']?? 'Live', style: TextStyle(color: Color(0xFF00E5FF)))));
    });
  }
}
