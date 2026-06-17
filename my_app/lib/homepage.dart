import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Memopage.dart';   // ← 追加
import 'Taskpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ホーム"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),

          SizedBox(height: 20),

          // ▼ 既存の "1ページ目に遷移する"
          /*
          Center(
            child: TextButton(
              child: Text("1ページ目に遷移する"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirstPage(),
                  ),
                );
              },
            ),
          ),*/

          SizedBox(height: 10),

          // ▼ 新しい「Memopage へ移動」
          Center(
            child: TextButton(
          child: Text("メモページ"),
          onPressed: (){
            // （1） 指定した画面に遷移する
            Navigator.push(context, MaterialPageRoute(
              // （2） 実際に表示するページ(ウィジェット)を指定する
              builder: (context) => Memopage()
            ));
          },
        ),
          ),

          
          // ▼ 新しい「Taskpage へ移動」
          /*
          Center(
            child: ElevatedButton(
              child: Text("タスクページへ移動する"),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Taskpage()),
                );
              },
            ),
          ),*/
        ],
      ),
    );
  }
}
