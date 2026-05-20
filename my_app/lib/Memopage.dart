import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Memo_model.dart';
import 'Memo_write.dart'; // 修正済みの動的フォーム対応版
import 'MemoWritePageEditing.dart'; // 修正済みの動的フォーム対応版
import 'MemoCustomizePage.dart'; // 修正済みの安全版
import 'memo_comparison_page.dart';

class Memopage extends StatefulWidget {
  const Memopage({super.key}); // 【警告修正】constとsuper.keyを追加

  @override
  State<Memopage> createState() => _MemopageState(); // 【警告修正】プライベート型の公開API利用を回避
}

class _MemopageState extends State<Memopage> {
  List<Memo> memos = [];
  bool _isGridView = false;
  
  // 端末保存データがない場合のデフォルト初期値
  List<CustomField> customFields = [
    CustomField(name: "転勤の有無", type: FieldType.radio, options: ["有", "無"]),
    CustomField(name: "時給", type: FieldType.number),
    CustomField(name: "兼業の可否", type: FieldType.radio, options: ["可", "否"]),
    CustomField(name: "志望度", type: FieldType.radio, options: ["◎","〇","△","×","？"]),
  ];

  @override
  void initState() {
    super.initState();
    loadData(); // メモとカスタム項目を一括読み込み
  }

  // メモとカスタム項目を両方読み込む
  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // メモの読み込み
    final memoList = prefs.getStringList("memos") ?? [];
    
    // カスタム項目の読み込み（なければデフォルト値を使用）
    final fieldList = prefs.getStringList("custom_fields") ?? [];

    setState(() {
      memos = memoList.map((e) => Memo.fromJson(jsonDecode(e))).toList();
      if (fieldList.isNotEmpty) {
        customFields = fieldList.map((e) => CustomField.fromJson(jsonDecode(e))).toList();
      }
      sortMemos();
    });
  }

  // メモデータを保存
  void saveMemos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final memoList = memos.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList("memos", memoList);
  }

  // カスタム項目データを保存
  void saveCustomFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final fieldList = customFields.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList("custom_fields", fieldList);
  }

  void sortMemos() {
    memos.sort((a, b) => a.title.compareTo(b.title));
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "未対応": return const Color.fromARGB(255, 3, 116, 82);
      case "面談": return const Color.fromARGB(255, 21, 109, 180);
      case "１次～選考": return const Color.fromARGB(255, 161, 100, 8);
      case "選考インターン": return const Color.fromARGB(255, 130, 67, 141);
      case "最終選考": return const Color.fromARGB(255, 150, 0, 102);
      case "内定": return const Color.fromARGB(255, 0, 122, 4);
      case "終了": return Colors.grey;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("就活メモ一覧"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() { _isGridView = !_isGridView; });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoCustomizePage(fields: List.from(customFields)),
                    ),
                  );
                  if (result != null && result is List<CustomField>) {
                    setState(() {
                      customFields = result;
                      saveCustomFields(); // カスタマイズ内容を即時端末保存
                    });
                  }
                },
                child: const Text("項目カスタマイズ"),
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows),
                label: const Text("条件比較"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoComparisonPage(
                        memos: memos, 
                        customFields: customFields,
                      ),
                    ),
                  );
                },
              ),

              TextButton(
                child: const Text("ホームへ戻る"),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
          Expanded(
            child: memos.isEmpty 
                ? const Center(child: Text("メモがありません。右下の＋から追加してください。"))
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.3),
                        itemCount: memos.length,
                        itemBuilder: (context, index) => memoCard(memos[index]),
                      )
                    : ListView.builder(
                        itemCount: memos.length,
                        itemBuilder: (context, index) => memoCard(memos[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemoWritePage(customFields: customFields),
            ),
          );
          if (result != null && result is String) {
            setState(() {
              memos.add(Memo.fromJson(jsonDecode(result)));
              sortMemos(); // 追加後すぐにソート
              saveMemos();
            });
          }
        },
      ),
    );
  }
  
  Widget memoCard(Memo memo) {
    return Dismissible(
      key: Key(memo.title + memo.date.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        setState(() {
          memos.remove(memo);
          saveMemos();
        });
      },
      child: Card( 
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: getStatusColor(memo.status),
            radius: 12,
          ),
          title: Text(memo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            "${memo.status} \n${memo.content}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemoWritePageEditing(
                    memo: memo, customFields: customFields),
              ),
            );
            if (result != null && result is String) {
              setState(() {
                final index = memos.indexOf(memo);
                if (index != -1) {
                  memos[index] = Memo.fromJson(jsonDecode(result));
                  sortMemos(); // 編集後もきれいに再ソート
                  saveMemos();
                }
              });
            }
          },
        ),
      ),
    );
  }
}
