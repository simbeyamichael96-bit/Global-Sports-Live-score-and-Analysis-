import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sports_controller.dart';

class HomeScreen extends StatelessWidget {
  final c = Get.put(SportsController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Global Sports Live'), backgroundColor: Colors.green),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              onChanged: (v){
                if(v.length >= 3) c.searchLeagues(v);
                else if(v.isEmpty) c.searchLeagues("");
              },
              decoration: InputDecoration(
                hintText: 'Andika herufi 3: yan, ars, bar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(child: Obx(()=> ListView.builder(
            itemCount: c.filteredMatches.length,
            itemBuilder: (ctx,i){
              final m=c.filteredMatches[i];
              return Card(child: ListTile(title: Text("${m.homeTeam} vs ${m.awayTeam}"), subtitle: Text(m.league), trailing: Text(m.score, style: TextStyle(fontWeight: FontWeight.bold))));
            },
          ))),
        ],
      ),
    );
  }
}
