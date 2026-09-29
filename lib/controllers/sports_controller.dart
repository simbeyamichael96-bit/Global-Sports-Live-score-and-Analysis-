import 'package:get/get.dart';
import '../models/match_model.dart';
class SportsController extends GetxController {
  var allMatches=<MatchModel>[].obs;
  var filteredMatches=<MatchModel>[].obs;
  @override
  void onInit(){super.onInit(); load();}
  void load(){
    allMatches.value=[
      MatchModel(league:"NBC Premier",homeTeam:"Yanga",awayTeam:"Simba",time:"19:00",score:"0-0"),
      MatchModel(league:"Premier League",homeTeam:"Arsenal",awayTeam:"Man City",time:"17:30",score:"1-0"),
      MatchModel(league:"La Liga",homeTeam:"Barcelona",awayTeam:"Real Madrid",time:"21:00",score:"2-2"),
      MatchModel(league:"Bundesliga",homeTeam:"Bayern",awayTeam:"Dortmund",time:"19:30",score:"0-1"),
      MatchModel(league:"NBA",homeTeam:"Lakers",awayTeam:"Warriors",time:"02:00",score:"102-98"),
    ];
    filteredMatches.value=allMatches;
  }
  void searchLeagues(String q){
    if(q.length < 3){filteredMatches.value=allMatches; return;}
    final s=q.toLowerCase();
    filteredMatches.value=allMatches.where((m)=> m.league.toLowerCase().contains(s) || m.homeTeam.toLowerCase().contains(s) || m.awayTeam.toLowerCase().contains(s)).toList();
  }
}
