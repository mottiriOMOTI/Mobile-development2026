import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Memopage.dart';
import 'Taskpage.dart';

// 先ほど作成したAIチャットのファイルをインポート（ファイル名は適宜合わせてください）
import 'ai_chat_support.dart'; 
import 'Memo_model.dart'; // Memoクラスのインポート

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ※重要: AIに分析させるためのメモデータ
  // 本来はSQLite(データベース)やSharedPreferences、Provider等から取得した全メモをここに入れます。
  // 今回はエラーが出ないよう空のリストを置いています。
  List<Memo> _allMemos = []; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ホーム"),
      ),
      body: SingleChildScrollView( // 画面が溢れないようにスクロール可能にしておくのがおすすめです
        child: Column(
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

            const SizedBox(height: 20),

            // ▼ 既存の「Memopage へ移動」ボタン
            Center(
              child: TextButton(
                child: const Text("メモページ", style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const Memopage()
                  ));
                },
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // ▼ 新規追加：「AIに自己分析まとめを依頼する」ボタン
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  "これまでのメモから自己分析まとめを作成",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4f46e5), // AIっぽいインディゴブルー
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50), // 横幅いっぱいに広げる
                  elevation: 2,
                ),
                onPressed: () {
                  // ボタンを押すと、初期メッセージ付きでAIチャットが下から立ち上がる
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AiChatBottomSheet(
                      memos: _allMemos, // 蓄積された全メモデータを渡す
                      initialUserMessage: "これまでに私が入力した就活メモの内容全体を分析して、私の強みや会社選びの軸（価値観）をまとめてください。",
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      
      // ==========================================
      // ▼ 新規追加：常に右下に表示される「AI相談」FAB
      // ==========================================
      floatingActionButton: buildAiChatButton(context, _allMemos),
    );
  }
}