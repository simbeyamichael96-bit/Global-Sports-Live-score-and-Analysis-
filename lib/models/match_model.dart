class LiveMatch {
  String id;
  String sport;
  String league;
  String homeTeam;
  String awayTeam;
  String homeScore;
  String awayScore;
  String time;
  bool isLive;
  String country;

  LiveMatch({
    required this.id,
    required this.sport,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.time,
    required this.isLive,
    required this.country,
  });
}

// Compatibility - ili code ya zamani isivunjike
class MatchModel {
  final String league, homeTeam, awayTeam, time, score;
  MatchModel({required this.league, required this.homeTeam, required this.awayTeam, required this.time, required this.score});
}
