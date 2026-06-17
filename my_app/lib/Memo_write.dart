import 'package:flutter/material.dart';
import 'dart:convert';
import 'Memo_model.dart';
import 'package:flutter/services.dart'; 

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

  // カスタムフィールド用の状態管理
  final Map<String, TextEditingController> textControllers = {};
  final Map<String, String> selectedValues = {};

  // スケジュール用の状態管理
  final List<Map<String, dynamic>> schedules = [];
  final TextEditingController scheduleTitleController = TextEditingController();
  DateTime? selectedScheduleDate;
  TimeOfDay? selectedScheduleTime;

  final List<String> statuses = [
    "未対応", "面談", "１次～選考", "選考インターン", "最終選考", "内定", "終了"
  ];

  @override
  void initState() {
    super.initState();
    // カスタムフィールドの初期化
    for (var f in widget.customFields) {
      if (f.type == FieldType.text || f.type == FieldType.number) {
        textControllers[f.name] = TextEditingController();
      } else if (f.type == FieldType.radio || f.type == FieldType.dropdown) {
        // 初期値として最初の選択肢を設定（選択肢が空なら空文字）
        selectedValues[f.name] = (f.options != null && f.options!.isNotEmpty)
            ? f.options!.first
            : "";
      }
    }
  }

  // 日付選択ダイアログを表示する関数
  Future<void> _pickScheduleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedScheduleDate = picked;
      });
    }
  }

  // 時刻選択ダイアログを表示する関数
  Future<void> _pickScheduleTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedScheduleTime = picked;
      });
    }
  }

  // スケジュールをリストに追加する関数
  void _addSchedule() {
    if (scheduleTitleController.text.isEmpty || 
        selectedScheduleDate == null || 
        selectedScheduleTime == null) return;

    final combinedDateTime = DateTime(
      selectedScheduleDate!.year,
      selectedScheduleDate!.month,
      selectedScheduleDate!.day,
      selectedScheduleTime!.hour,
      selectedScheduleTime!.minute,
    );

    setState(() {
      schedules.add({
        'title': scheduleTitleController.text,
        'date': combinedDateTime.toIso8601String(),
      });
      scheduleTitleController.clear();
      selectedScheduleDate = null;
      selectedScheduleTime = null;
    });
  }

  // カスタムフィールドの種類に応じたWidgetを生成する関数
  Widget _buildCustomFieldInput(CustomField field) {
    switch (field.type) {
      case FieldType.text:
        return TextField(
          controller: textControllers[field.name],
          decoration: InputDecoration(labelText: field.name),
        );
       case FieldType.number:
      return TextField(
        controller: textControllers[field.name],
        // キーボードを数字専用に変更
        keyboardType: TextInputType.number, 
        // 数字（0〜9）以外の入力を完全に禁止するフィルター
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
        decoration: InputDecoration(
          labelText: "${field.name} (数値のみ)",
          hintText: "数字を入力してください",
        ),
      );
      case FieldType.dropdown:
        return Row(
          children: [
            Text("${field.name}: "),
            DropdownButton<String>(
              value: selectedValues[field.name],
              items: (field.options ?? []).map((opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  selectedValues[field.name] = val!;
                });
              },
            ),
          ],
        );
      case FieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.name, style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: (field.options ?? []).map((opt) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: opt,
                    groupValue: selectedValues[field.name],
                    onChanged: (val) {
                      setState(() {
                        selectedValues[field.name] = val!;
                      });
                    },
                  ),
                  Text(opt),
                ],
              )).toList(),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("メモを書く")),
      body: SingleChildScrollView( // 画面幅を超えたときのためのスクロール対応
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "タイトル")),
            TextField(controller: contentController, decoration: InputDecoration(labelText: "内容")),
            SizedBox(height: 10),
            Text("ステータス", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: statuses.map((s) => ChoiceChip(
                label: Text(s),
                selected: status == s,
                onSelected: (_) { setState(() { status = s; }); },
              )).toList(),
            ),
            Divider(),
            Text("カスタム項目", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...widget.customFields.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildCustomFieldInput(f),
            )),
            Divider(),
            Text("スケジュール追加", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: scheduleTitleController,
              decoration: InputDecoration(labelText: "予定名 (例: 一次面接)"),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selectedScheduleDate == null 
                          ? "日付未選択" 
                          : "日: ${selectedScheduleDate!.toLocal().toString().split(' ')[0]}"),
                      Text(selectedScheduleTime == null 
                          ? "時刻未選択" 
                          : "時: ${selectedScheduleTime!.format(context)}"),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _pickScheduleDate(context),
                  child: Text("日付"),
                ),
                TextButton(
                  onPressed: () => _pickScheduleTime(context),
                  child: Text("時刻"),
                ),
                ElevatedButton(onPressed: _addSchedule, child: Text("予定を追加")),
              ],
            ),
            // 追加されたスケジュールの一覧表示
            ...schedules.map((s) => ListTile(
              title: Text(s['title']),
              subtitle: Text(s['date'].replaceFirst('T', ' ').substring(0, 16)),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() { schedules.remove(s); });
                },
              ),
            )).toList(),
            Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text("保存"),
                onPressed: () {
                  Map<String, dynamic> customData = {};
                  // テキスト・数値のデータを回収
                  textControllers.forEach((key, value) {
                    customData[key] = value.text;
                  });
                  // ラジオボタン・ドロップダウンのデータを回収
                  selectedValues.forEach((key, value) {
                    customData[key] = value;
                  });

                  final memo = Memo(
                    title: titleController.text,
                    content: contentController.text,
                    date: DateTime.now(),
                    status: status,
                    customFields: customData,
                    schedules: schedules, // スケジュールリストを渡す
                  );
                  Navigator.pop(context, jsonEncode(memo.toJson()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
