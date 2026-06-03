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

  // 選考状況に応じた色（より洗練されたパステル＆ディープカラーに変更）
  Color _getStatusColor(String status) {
    switch (status) {
      case "未対応": return const Color(0xff0284c7); // スカイブルー
      case "面談": return const Color(0xff3b82f6); // インディゴ
      case "１次～選考": return const Color(0xfff59e0b); // アンバー
      case "選考インターン": return const Color(0xff8b5cf6); // パープル
      case "最終選考": return const Color(0xffec4899); // ピンク
      case "内定": return const Color(0xff10b981); // エメラルドグリーン
      case "終了": return const Color(0xff6b7280); // グレー
      default: return const Color(0xff1f2937);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc), // スレート系の明るい背景色
      appBar: AppBar(
        title: const Text(
          "就活ステータス比較",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1e293b),
        // AppBarの下線は shape 属性を使って正しく表現します
        shape: const Border(
          bottom: BorderSide(color: Color(0xffe2e8f0), width: 1),
        ),
      ),
      body: memos.isEmpty
          ? const Center(
              child: Text(
                "比較するメモがありません。",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // 角丸でモダンに
                  border: Border.all(color: const Color(0xffe2e8f0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      // withOpacityの代わりにwithValuesを使用
                      color: const Color(0xff0f172a).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 横スクロール
                  child: Theme(
                    // テーブル専用のスタイル調整
                    data: theme.copyWith(
                      dividerColor: const Color(0xfff1f5f9),
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xfff8fafc)), // ヘッダー背景
                      headingRowHeight: 52,
                      dataRowMinHeight: 56, // 行の高さを広げてゆとりを持たせる
                      dataRowMaxHeight: 56,
                      horizontalMargin: 20,
                      columnSpacing: 28,
                      columns: [
                        const DataColumn(
                          label: Text(
                            "企業名",
                            style: TextStyle(color: Color(0xff334155), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            "進み具合",
                            style: TextStyle(color: Color(0xff334155), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        ...customFields.map((field) => DataColumn(
                              label: Text(
                                field.name,
                                style: const TextStyle(color: Color(0xff334155), fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            )),
                      ],
                      rows: memos.map((memo) {
                        final statusColor = _getStatusColor(memo.status);
                        return DataRow(
                          cells: [
                            // 企業名（太字で強調）
                            DataCell(
                              Text(
                                memo.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff0f172a),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // ステータスバッジ（丸みのあるお洒落なチップ UI）
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  // withOpacityの代わりにwithValuesを使用
                                  color: statusColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(100), // カプセル型
                                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                                ),
                                child: Text(
                                  memo.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            // カスタマイズされた項目（未入力時はグレーの「-」）
                            ...customFields.map((field) {
                              final value = memo.customFields[field.name]?.toString() ?? "";
                              final isEmpty = value.isEmpty || value == "-";
                              return DataCell(
                                Text(
                                  isEmpty ? "-" : value,
                                  style: TextStyle(
                                    color: isEmpty ? const Color(0xff94a3b8) : const Color(0xff334155),
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
