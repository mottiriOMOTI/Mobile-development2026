import 'package:flutter/material.dart';
import 'dart:convert';
import 'Memo_model.dart';

class MemoWritePageEditing extends StatefulWidget {
  final Memo memo;
  final List<CustomField> customFields;

  MemoWritePageEditing({required this.memo, this.customFields = const []});

  @override
  _MemoWritePageEditingState createState() => _MemoWritePageEditingState();
}

class _MemoWritePageEditingState extends State<MemoWritePageEditing> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late String status;
  Map<String, TextEditingController> controllers = {};

  final List<String> statuses = [
    "未対応","面談","１次～選考","選考インターン","最終選考","内定","終了"
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.memo.title);
    contentController = TextEditingController(text: widget.memo.content);
    status = widget.memo.status;

    for (var f in widget.customFields) {
      controllers[f.name] = TextEditingController(
        text: widget.memo.customFields[f.name]?.toString() ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("メモ編集")),
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
              child: Text("更新"),
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
