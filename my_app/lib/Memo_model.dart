class Memo {
  String title;
  String content;
  DateTime date;
  String status;
  Map<String, dynamic> customFields;
  List<Map<String, dynamic>> schedules;

  Memo({
    required this.title,
    required this.content,
    required this.date,
    required this.status,
    Map<String, dynamic>? customFields,
    List<Map<String, dynamic>>? schedules,
  })  : customFields = customFields ?? {},
        schedules = schedules ?? [];

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      schedules: List<Map<String, dynamic>>.from(json['schedules'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'status': status,
      'customFields': customFields,
      'schedules': schedules,
    };
  }
}

enum FieldType { text, number, radio, dropdown }

// Memo_model.dart 内の CustomField クラスに以下を追加
class CustomField {
  String name;
  FieldType type;
  List<String>? options;

  CustomField({
    required this.name,
    required this.type,
    this.options,
  });

  // 【これが無いと保存・読み込みに失敗します】
  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      name: json['name'],
      type: FieldType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  // 【これが無いと保存・読み込みに失敗します】
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'options': options,
    };
  }
}


