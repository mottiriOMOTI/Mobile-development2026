import 'package:flutter/material.dart';
import 'dart:convert';
import 'Memo_model.dart';
import 'package:flutter/services.dart'; 

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

  // カスタムフィールド用の状態管理
  final Map<String, TextEditingController> textControllers = {};
  final Map<String, String> selectedValues = {};

  // スケジュール用の状態管理（既存データをコピーして初期化）
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
    titleController = TextEditingController(text: widget.memo.title);
    contentController = TextEditingController(text: widget.memo.content);
    status = widget.memo.status;

    // 既存のスケジュールデータをディープコピーして保持
    schedules.addAll(List<Map<String, dynamic>>.from(widget.memo.schedules));

    // カスタムフィールドの初期化（既存データがあればそれを優先、なければ空）
    for (var f in widget.customFields) {
      final savedValue = widget.memo.customFields[f.name]?.toString();

      if (f.type == FieldType.text || f.type == FieldType.number) {
        textControllers[f.name] = TextEditingController(text: savedValue ?? '');
      } else if (f.type == FieldType.radio || f.type == FieldType.dropdown) {
        // 保存された値があるか確認、なければ最初の選択肢を初期値にする
        selectedValues[f.name] = savedValue ?? 
            ((f.options != null && f.options!.isNotEmpty) ? f.options!.first : "");
      }
    }
  }

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
      appBar: AppBar(title: Text("メモ編集")),
      body: SingleChildScrollView(
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
            Text("スケジュール編集", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: scheduleTitleController,
              decoration: InputDecoration(labelText: "予定名 (例: 二次面接)"),
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
                child: Text("更新"),
                onPressed: () {
                  Map<String, dynamic> customData = {};
                  textControllers.forEach((key, value) {
                    customData[key] = value.text;
                  });
                  selectedValues.forEach((key, value) {
                    customData[key] = value;
                  });

                  final memo = Memo(
                    title: titleController.text,
                    content: contentController.text,
                    date: widget.memo.date, // 作成日は維持
                    status: status,
                    customFields: customData,
                    schedules: schedules, // 更新されたスケジュールリストを渡す
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
