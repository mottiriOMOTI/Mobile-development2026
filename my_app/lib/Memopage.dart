import 'package:flutter/material.dart';
import 'package:my_app/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Memo_model.dart';
import 'Memo_write.dart';
import 'MemoWritePageEditing.dart';
import 'MemoCustomizePage.dart';

class Memopage extends StatefulWidget {
  @override
  _MemopageState createState() => _MemopageState();
}

class _MemopageState extends State<Memopage> {
  List<Memo> memos = [];
  bool _isGridView = false;
  List<CustomField> customFields = [
    CustomField(name: "転勤の有無", type: FieldType.radio, options: ["有", "無"]),
    CustomField(name: "時給", type: FieldType.number),
    CustomField(name: "兼業の可否", type: FieldType.radio, options: ["可", "否"]),
    CustomField(name: "志望度", type: FieldType.radio, options: ["◎","〇","△","×","？"]),
  ];

  @override
  void initState() {
    super.initState();
    loadMemos();
  }

  void loadMemos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final memoList = prefs.getStringList("memos") ?? [];
    setState(() {
      memos = memoList.map((e) => Memo.fromJson(jsonDecode(e))).toList();
      sortMemos();
    });
  }

  void saveMemos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final memoList = memos.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList("memos", memoList);
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
        title: Text("メモページ"),
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
          });
        }
      },
      child: Text("カスタマイズ"),
    ),

    // ★ 追加部分 ★
    TextButton(
      child: Text("ホームページに遷移する"),
      onPressed: () {
        Navigator.push(
          context,
                MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
    ),
  ],
),

          Expanded(
            child: _isGridView
                ? GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
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
        child: Icon(Icons.add),
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
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        setState(() {
          memos.remove(memo);
          saveMemos();
        });
      },
      child: ListTile(
        title: Text(memo.title),
        subtitle: Text(memo.content),
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
              memos[memos.indexOf(memo)] = Memo.fromJson(jsonDecode(result));
              saveMemos();
            });
          }
        },
      ),
    );
  }
}
