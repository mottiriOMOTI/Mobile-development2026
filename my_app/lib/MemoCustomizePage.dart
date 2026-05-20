import 'package:flutter/material.dart';
import 'Memo_model.dart';

class MemoCustomizePage extends StatefulWidget {
  final List<CustomField> fields;

  // 【警告修正】constを追加し、名前付き引数 key を追加しました
  const MemoCustomizePage({super.key, required this.fields});

  @override
  State<MemoCustomizePage> createState() => _MemoCustomizePageState();
}

// 【警告修正】公開API内の非推奨なプライベート型利用を解消するため
// createStateの戻り値を State<MemoCustomizePage> に明示変更しました
class _MemoCustomizePageState extends State<MemoCustomizePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController optionsController = TextEditingController();
  FieldType selectedType = FieldType.text;
  late List<CustomField> localFields;

  @override
  void initState() {
    super.initState();
    localFields = widget.fields.map((f) => CustomField(
      name: f.name,
      type: f.type,
      options: f.options != null ? List<String>.from(f.options!) : null,
    )).toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    optionsController.dispose();
    super.dispose();
  }

  void addCustomField() {
    if (nameController.text.trim().isEmpty) return;

    List<String>? finalOptions;
    if (selectedType == FieldType.radio || selectedType == FieldType.dropdown) {
      if (optionsController.text.trim().isEmpty) return;
      finalOptions = optionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    setState(() {
      localFields.add(CustomField(
        name: nameController.text.trim(),
        type: selectedType,
        options: finalOptions,
      ));
      nameController.clear();
      optionsController.clear();
      selectedType = FieldType.text;
    });
  }

  void removeField(int index) {
    if (localFields[index].name == "タイトル") return;
    setState(() {
      localFields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("メモカスタマイズ")), // constを付与
      body: Padding(
        padding: const EdgeInsets.all(16), // constを付与
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "項目名"), // constを付与
            ),
            DropdownButton<FieldType>(
              value: selectedType,
              items: FieldType.values
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text(e.toString().split('.').last)))
                  .toList(),
              onChanged: (v) {
                setState(() { selectedType = v!; });
              },
            ),
            if (selectedType == FieldType.radio || selectedType == FieldType.dropdown)
              TextField(
                controller: optionsController,
                decoration: const InputDecoration(labelText: "オプションをカンマ区切りで入力"), // constを付与
              ),
            ElevatedButton(onPressed: addCustomField, child: const Text("追加")), // constを付与
            const Divider(), // constを付与
            Expanded(
              child: ListView.builder(
                itemCount: localFields.length,
                itemBuilder: (context, index) {
                  final field = localFields[index];
                  return ListTile(
                    title: Text(field.name),
                    subtitle: Text(field.type.toString().split('.').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete), // constを付与
                      onPressed: () => removeField(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, localFields); 
                },
                child: const Text("保存")) // constを付与
          ],
        ),
      ),
    );
  }
}
