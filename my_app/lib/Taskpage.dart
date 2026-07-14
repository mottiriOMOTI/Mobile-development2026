import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Memopage.dart';
import 'HomePage.dart';
import 'Schedule_write.dart'; // 予定を書く画面（必要であれば）

class Taskpage extends StatefulWidget {
  @override
  _TaskpageState createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  // 保存された予定を読み込む
  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedSchedules = prefs.getStringList('schedules') ?? [];
    
    setState(() {
      schedules = savedSchedules.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("タスク・予定一覧")),
      body: Column(
        children: [
          // 予定リスト表示エリア
          Expanded(
            child: schedules.isEmpty
                ? Center(child: Text("登録された予定はありません"))
                : ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final item = schedules[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(item['title'] ?? ""),
                          subtitle: Text("${item['date']} ${item['time']}"),
                          trailing: item['notify'] == true ? Icon(Icons.notifications_active, color: Colors.blue) : null,
                        ),
                      );
                    },
                  ),
          ),
          
          // 下部のナビゲーションボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text("ホームへ"),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage())),
                ),
                ElevatedButton(
                  child: Text("メモページへ"),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Memopage())),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 予定追加画面へ遷移（追加後にリストを再読み込み）
          await Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleWritePage()));
          _loadSchedules();
        },
      ),
    );
  }
}