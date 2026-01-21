import 'package:flutter/material.dart';

class MemoEditPage extends StatefulWidget {
  final String oldMemo;

  MemoEditPage({required this.oldMemo});

  @override
  _MemoEditPageState createState() => _MemoEditPageState();
}

class _MemoEditPageState extends State<MemoEditPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.oldMemo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("メモを編集")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("更新する"),
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
