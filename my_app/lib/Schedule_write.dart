import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart';

class ScheduleWritePage extends StatefulWidget {
  const ScheduleWritePage({super.key});

  @override
  State<ScheduleWritePage> createState() => _ScheduleWritePageState();
}

class _ScheduleWritePageState extends State<ScheduleWritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool notify = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("予定を書く")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration:
                  InputDecoration(labelText: "タイトル", border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration:
                  InputDecoration(labelText: "内容", border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("日付: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"),
                const Spacer(),
                TextButton(onPressed: _selectDate, child: const Text("選択")),
              ],
            ),
            Row(
              children: [
                Text("時間: ${selectedTime.format(context)}"),
                const Spacer(),
                TextButton(onPressed: _selectTime, child: const Text("選択")),
              ],
            ),
            Row(
              children: [
                Text("通知"),
                Spacer(),
                Switch(value: notify, onChanged: (val) => setState(() => notify = val)),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text("保存"),
              onPressed: () async {
                final scheduleData = {
                  "title": titleController.text,
                  "content": contentController.text,
                  "date": selectedDate.toIso8601String(),
                  "time": "${selectedTime.hour}:${selectedTime.minute}",
                  "notify": notify,
                };

                if (notify) {
                  // 日付と時間を組み合わせて DateTime オブジェクトを作成
                  final scheduledDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  
                  await NotificationService().scheduleNotification(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // 簡易的なID生成
                    title: titleController.text,
                    body: contentController.text,
                    scheduledDate: scheduledDateTime,
                  );
                }

                // --- ここでデータを保存する ---
                final prefs = await SharedPreferences.getInstance();
                // 既存のリストを取得
                List<String> schedules = prefs.getStringList('schedules') ?? [];
                // 新しいデータを追加（JSON文字列に変換）
                schedules.add(jsonEncode(scheduleData));
                // 保存
                await prefs.setStringList('schedules', schedules);

                if (!mounted) return;
                Navigator.pop(context, scheduleData);
              },
            ),
          ],
        ),
      ),
    );
  }
}
