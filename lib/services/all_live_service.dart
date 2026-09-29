import 'dart:convert';
import 'package:http/http.dart' as http;

class AllLiveService {
  // CHUKUA KEY BURE HAPA: https://www.api-football.com/ -> Sign Up Free
  // Utapata 100 request / siku bure
  static const String apiKey = 'PASTE_KEY_YAKO_HAPA';

  Future<List> getLive() async {
    if (apiKey.contains('PASTE')) {
      // Kabla ya KEY - inarudisha data ya mfano ili app isifeli
      return [];
    }
    var r = await http.get(
      Uri.parse('https://v3.football.api-sports.io/fixtures?live=all'),
      headers: {'x-apisports-key': apiKey},
    );
    if (r.statusCode == 200) return json.decode(r.body)['response'];
    return [];
  }

  Future<List> getToday() async {
    if (apiKey.contains('PASTE')) return [];
    String today = DateTime.now().toIso8601String().split('T')[0];
    var r = await http.get(
      Uri.parse('https://v3.football.api-sports.io/fixtures?date=$today'),
      headers: {'x-apisports-key': apiKey},
    );
    if (r.statusCode == 200) return json.decode(r.body)['response'];
    return [];
  }
}
