import 'package:flutter/material.dart';

class ScheduleWritePage extends StatefulWidget {
  @override
  _ScheduleWritePageState createState() => _ScheduleWritePageState();
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
                Spacer(),
                TextButton(child: Text("選択"), onPressed: _selectDate),
              ],
            ),
            Row(
              children: [
                Text("時間: ${selectedTime.format(context)}"),
                Spacer(),
                TextButton(child: Text("選択"), onPressed: _selectTime),
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
              onPressed: () {
                Navigator.pop(context, {
                  "title": titleController.text,
                  "content": contentController.text,
                  "date": selectedDate.toIso8601String(),
                  "time": selectedTime.format(context),
                  "notify": notify,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
