import 'package:flutter/material.dart';
import 'Memo_model.dart';

class MemoComparisonPage extends StatefulWidget {
  final List<Memo> memos;
  final List<CustomField> customFields;

  const MemoComparisonPage({
    super.key,
    required this.memos,
    required this.customFields,
  });

  @override
  State<MemoComparisonPage> createState() => _MemoComparisonPageState();
}

class _MemoComparisonPageState extends State<MemoComparisonPage> {
  // 注目する項目（nullの場合はすべて表示）
  CustomField? _selectedField;

  // 選考状況に応じた色
  Color _getStatusColor(String status) {
    switch (status) {
      case "未対応": return const Color(0xff0284c7);
      case "面談": return const Color(0xff3b82f6);
      case "１次～選考": return const Color(0xfff59e0b);
      case "選考インターン": return const Color(0xff8b5cf6);
      case "最終選考": return const Color(0xffec4899);
      case "内定": return const Color(0xff10b981);
      case "終了": return const Color(0xff6b7280);
      default: return const Color(0xff1f2937);
    }
  }

  // 選択された項目が数値の場合、全メモの中での最大値を取得する
  double _getMaxValue(CustomField field) {
    double max = 0;
    for (var memo in widget.memos) {
      final valueStr = memo.customFields[field.name]?.toString() ?? "";
      final value = double.tryParse(valueStr);
      if (value != null && value > max) {
        max = value;
      }
    }
    return max == 0 ? 1 : max; // 0除算を防ぐ
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text(
          "就活ステータス比較",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1e293b),
        shape: const Border(
          bottom: BorderSide(color: Color(0xffe2e8f0), width: 1),
        ),
      ),
      body: widget.memos.isEmpty
          ? const Center(
              child: Text(
                "比較するメモがありません。",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : Column(
              children: [
                // --- 項目選択用のドロップダウン ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Color(0xff64748b)),
                      const SizedBox(width: 8),
                      const Text(
                        "注目する項目:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff334155)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<CustomField?>(
                          value: _selectedField,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xff64748b)),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("すべて表示 (テーブル)"),
                            ),
                            ...widget.customFields.map((field) {
                              return DropdownMenuItem(
                                value: field,
                                child: Text(field.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedField = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xffe2e8f0)),
                
                // --- メインコンテンツ ---
                Expanded(
                  child: _selectedField == null
                      ? _buildAllDataTable(theme) // すべて表示モード
                      : _buildFocusedList(),      // 注目モード（棒グラフあり）
                ),
              ],
            ),
    );
  }

  // --- 注目モード（棒グラフや個別比較を表示） ---
  Widget _buildFocusedList() {
    final field = _selectedField!;
    final maxValue = _getMaxValue(field);

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.memos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final memo = widget.memos[index];
        final statusColor = _getStatusColor(memo.status);
        final valueStr = memo.customFields[field.name]?.toString() ?? "";
        final isEmpty = valueStr.isEmpty || valueStr == "-";
        
        // 数値に変換できるかチェック
        final numValue = double.tryParse(valueStr);
        final isNumeric = numValue != null;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffe2e8f0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff0f172a).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部（企業名とステータス）
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      memo.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0f172a),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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
                ],
              ),
              const SizedBox(height: 16),
              
              // 値の表示部（数値なら棒グラフ、テキストならそのまま）
              if (isEmpty)
                const Text("-", style: TextStyle(color: Color(0xff94a3b8)))
              else if (isNumeric)
                _buildBarChart(numValue, maxValue, valueStr)
              else
                Text(
                  valueStr,
                  style: const TextStyle(color: Color(0xff334155), fontSize: 15),
                ),
            ],
          ),
        );
      },
    );
  }

  // 棒グラフを描画するウィジェット
  Widget _buildBarChart(double value, double maxValue, String displayStr) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // 背景のバー（グレー）
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xfff1f5f9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // 値のバー（青）アニメーション付き
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    height: 20,
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: const Color(0xff3b82f6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            displayStr,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff0f172a),
            ),
          ),
        ),
      ],
    );
  }

  // --- 従来の全体テーブル表示 ---
  Widget _buildAllDataTable(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffe2e8f0), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0f172a).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: theme.copyWith(
              dividerColor: const Color(0xfff1f5f9),
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xfff8fafc)),
              headingRowHeight: 52,
              dataRowMinHeight: 56,
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
                ...widget.customFields.map((field) => DataColumn(
                      label: Text(
                        field.name,
                        style: const TextStyle(color: Color(0xff334155), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    )),
              ],
              rows: widget.memos.map((memo) {
                final statusColor = _getStatusColor(memo.status);
                return DataRow(
                  cells: [
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
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
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
                    ...widget.customFields.map((field) {
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
    );
  }
}