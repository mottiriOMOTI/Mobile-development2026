import 'package:flutter/material.dart';
import 'dart:convert';
import 'Memo_model.dart';

class MemoWritePage extends StatefulWidget {
  final List<CustomField> customFields;

  MemoWritePage({this.customFields = const []});

  @override
  _MemoWritePageState createState() => _MemoWritePageState();
}

class _MemoWritePageState extends State<MemoWritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String status = "未対応";
  Map<String, TextEditingController> controllers = {};

  final List<String> statuses = [
    "未対応","面談","１次～選考","選考インターン","最終選考","内定","終了"
  ];

  @override
  void initState() {
    super.initState();
    for (var f in widget.customFields) {
      controllers[f.name] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("メモを書く")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "タイトル")),
            TextField(controller: contentController, decoration: InputDecoration(labelText: "内容")),
            Wrap(
              spacing: 10,
              children: statuses.map((s) => ChoiceChip(
                label: Text(s),
                selected: status == s,
                onSelected: (_) { setState(() { status = s; }); },
              )).toList(),
            ),
            ...widget.customFields.map((f) {
              return TextField(
                controller: controllers[f.name],
                decoration: InputDecoration(labelText: f.name),
              );
            }).toList(),
            ElevatedButton(
              child: Text("保存"),
              onPressed: () {
                Map<String, dynamic> customData = {};
                controllers.forEach((key, value) {
                  customData[key] = value.text;
                });
                final memo = Memo(
                  title: titleController.text,
                  content: contentController.text,
                  date: DateTime.now(),
                  status: status,
                  customFields: customData,
                );
                Navigator.pop(context, jsonEncode(memo.toJson()));
              },
            )
          ],
        ),
      ),
    );
  }
}
