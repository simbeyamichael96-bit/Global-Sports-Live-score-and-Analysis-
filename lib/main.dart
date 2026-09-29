import 'package:flutter/material.dart';
import 'services/all_live_service.dart';
import 'package:intl/intl.dart';

void main() => runApp(const GlobalSportsApp());

class GlobalSportsApp extends StatelessWidget {
  const GlobalSportsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Sports Live',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const LiveScreen(),
    );
  }
}

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});
  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final api = AllLiveService();
  List matches = [];
  bool loading = true;
  String tab = 'live';

  @override
  void initState() { super.initState(); load(); }

  load() async {
    setState(() => loading = true);
    List data = tab == 'live'? await api.getLive() : await api.getToday();
    setState(() { matches = data; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(tab == 'live'? 'LIVE SASA (${matches.length})' : 'MECHI ZA LEO (${matches.length})'),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton(
              segments: const [
                ButtonSegment(value: 'live', label: Text('LIVE'), icon: Icon(Icons.live_tv, color: Colors.red)),
                ButtonSegment(value: 'today', label: Text('LEO'), icon: Icon(Icons.calendar_today)),
              ],
              selected: {tab},
              onSelectionChanged: (s) { setState(() => tab = s.first); load(); },
            ),
          ),
          Expanded(
            child: loading
               ? const Center(child: CircularProgressIndicator())
                : matches.isEmpty
                   ? const Center(child: Text('Hakuna mechi. Weka API KEY kwenye all_live_service.dart\nau jaribu baadaye.', textAlign: TextAlign.center))
                    : ListView.builder(
                        itemCount: matches.length,
                        itemBuilder: (c, i) {
                          var f = matches[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: Text('${f['goals']['home']?? 0}-${f['goals']['away']?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              title: Text('${f['teams']['home']['name']} vs ${f['teams']['away']['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${f['league']['name']} - ${f['league']['country']} - ${f['fixture']['status']['long']} ${f['fixture']['status']['elapsed']?? ''}\''),
                              trailing: Text(f['fixture']['status']['short'], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
