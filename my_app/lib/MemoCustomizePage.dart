import 'package:flutter/material.dart';
import 'Memo_model.dart';

class MemoCustomizePage extends StatefulWidget {
  final List<CustomField> fields;

  MemoCustomizePage({required this.fields});

  @override
  _MemoCustomizePageState createState() => _MemoCustomizePageState();
}

class _MemoCustomizePageState extends State<MemoCustomizePage> {
  final TextEditingController nameController = TextEditingController();
  FieldType selectedType = FieldType.text;
  List<String> options = [];

  void addCustomField() {
    if (nameController.text.isEmpty) return;
    setState(() {
      widget.fields.add(CustomField(
        name: nameController.text,
        type: selectedType,
        options: selectedType == FieldType.radio || selectedType == FieldType.dropdown
            ? List.from(options)
            : null,
      ));
      nameController.clear();
      options.clear();
      selectedType = FieldType.text;
    });
  }

  void removeField(int index) {
    if (widget.fields[index].name == "タイトル") return;
    setState(() {
      widget.fields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("メモカスタマイズ")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "項目名"),
            ),
            DropdownButton<FieldType>(
              value: selectedType,
              items: FieldType.values
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text(e.toString().split('.').last)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedType = v!;
                });
              },
            ),
            if (selectedType == FieldType.radio || selectedType == FieldType.dropdown)
              TextField(
                decoration: InputDecoration(labelText: "オプションをカンマ区切りで入力"),
                onChanged: (v) {
                  options = v.split(',').map((e) => e.trim()).toList();
                },
              ),
            ElevatedButton(onPressed: addCustomField, child: Text("追加")),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.fields.length,
                itemBuilder: (context, index) {
                  final field = widget.fields[index];
                  return ListTile(
                    title: Text(field.name),
                    subtitle: Text(field.type.toString().split('.').last),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeField(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, widget.fields);
                },
                child: Text("保存"))
          ],
        ),
      ),
    );
  }
}
