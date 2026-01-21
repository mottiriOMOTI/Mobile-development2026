import 'package:flutter/material.dart';
import 'Memopage.dart';
import 'HomePage.dart';

class Taskpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("タスクページ"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ▼ ホームへ遷移（スタックなし）
          TextButton(
            child: Text("ホームページに遷移する"),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),

          SizedBox(height: 20),

          // ▼ メモページへ遷移（スタックなし）
          ElevatedButton(
            child: Text("メモページに遷移する"),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Memopage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
