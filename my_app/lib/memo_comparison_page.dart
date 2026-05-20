import 'package:flutter/material.dart';
import 'Memo_model.dart';

class MemoComparisonPage extends StatelessWidget {
  final List<Memo> memos;
  final List<CustomField> customFields;

  const MemoComparisonPage({
    super.key,
    required this.memos,
    required this.customFields,
  });

  // 選考状況に応じた色を取得
  Color _getStatusColor(String status) {
    switch (status) {
      case "未対応": return const Color.fromARGB(255, 3, 116, 82);
      case "面談": return const Color.fromARGB(255, 21, 109, 180);
      case "１次～選考": return const Color.fromARGB(255, 161, 100, 8);
      case "選考インターン": return const Color.fromARGB(255, 130, 67, 141);
      case "最終選考": return const Color.fromARGB(255, 150, 0, 102);
      case "内定": return const Color.fromARGB(255, 0, 122, 4);
      case "終了": return Colors.grey;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("就活ステータス比較"),
      ),
      body: memos.isEmpty
          ? const Center(child: Text("比較するメモがありません。"))
          : SingleChildScrollView(
              scrollDirection: Axis.vertical, // 縦スクロール
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 横スクロール
                child: DataTable(
                  // 列の設定（企業名、ステータス、カスタム項目）
                  columns: [
                    const DataColumn(label: Text("企業名", style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text("進み具合", style: TextStyle(fontWeight: FontWeight.bold))),
                    ...customFields.map((field) => DataColumn(
                          label: Text(field.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                  ],
                  // 行の設定（登録された各企業データ）
                  rows: memos.map((memo) {
                    return DataRow(
                      cells: [
                        DataCell(Text(memo.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(memo.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _getStatusColor(memo.status)),
                            ),
                            child: Text(
                              memo.status,
                              style: TextStyle(color: _getStatusColor(memo.status), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // カスタマイズされた項目を動的に表示（未入力なら「-」）
                        ...customFields.map((field) {
                          final value = memo.customFields[field.name]?.toString() ?? "-";
                          return DataCell(
                            Text(value.isEmpty ? "-" : value),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
