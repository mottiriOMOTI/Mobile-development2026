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

class CustomField {
  String name;
  FieldType type;
  List<String>? options;

  CustomField({
    required this.name,
    required this.type,
    this.options,
  });
}
