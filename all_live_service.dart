import '../models/match_model.dart';

class AllLiveService {
  static List<LiveMatch> getAllLiveMatches() {
    return [
      LiveMatch(id: "1", sport: "Football", league: "NBC Premier League", homeTeam: "Yanga SC", awayTeam: "Simba SC", homeScore: "2", awayScore: "1", time: "78'", isLive: true, country: "TZ"),
      LiveMatch(id: "2", sport: "Football", league: "Premier League", homeTeam: "Man City", awayTeam: "Arsenal", homeScore: "1", awayScore: "1", time: "65'", isLive: true, country: "ENG"),
      LiveMatch(id: "3", sport: "Football", league: "La Liga", homeTeam: "Real Madrid", awayTeam: "Barcelona", homeScore: "3", awayScore: "2", time: "89'", isLive: true, country: "ESP"),
      LiveMatch(id: "20", sport: "NBA", league: "NBA", homeTeam: "Lakers", awayTeam: "Warriors", homeScore: "102", awayScore: "98", time: "Q4 2:34", isLive: true, country: "USA"),
      LiveMatch(id: "30", sport: "Tennis", league: "Wimbledon", homeTeam: "Djokovic", awayTeam: "Alcaraz", homeScore: "6", awayScore: "4", time: "Set 2", isLive: true, country: "UK"),
      LiveMatch(id: "40", sport: "Hockey", league: "NHL", homeTeam: "Maple Leafs", awayTeam: "Canadiens", homeScore: "3", awayScore: "2", time: "P3 10:20", isLive: true, country: "CAN"),
      LiveMatch(id: "50", sport: "Cricket", league: "IPL", homeTeam: "Mumbai Indians", awayTeam: "Chennai Super", homeScore: "156/4", awayScore: "120/3", time: "Over 15.3", isLive: true, country: "IND"),
      LiveMatch(id: "51", sport: "Cricket", league: "T20 World Cup", homeTeam: "Tanzania", awayTeam: "Kenya", homeScore: "89/2", awayScore: "78/5", time: "Over 12.1", isLive: true, country: "TZ"),
    ];
  }
  static List<LiveMatch> getBySport(String s) => s=="All"? getAllLiveMatches() : getAllLiveMatches().where((m)=>m.sport==s).toList();
}
