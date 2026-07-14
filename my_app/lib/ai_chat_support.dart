import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenvを追加
import 'package:google_generative_ai/google_generative_ai.dart'; // Gemini SDKを追加
import 'Memo_model.dart'; // メモモデルのインポート

/// 画面の右下に配置するAI相談ボタン（FloatingActionButton用）
Widget buildAiChatButton(BuildContext context, List<Memo> memos) {
  return FloatingActionButton.extended(
    heroTag: "ai_chat_fab", // 複数FAB配置時の競合を防ぐタグ
    onPressed: () {
      // タップすると下から簡易チャットが立ち上がる
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // キーボード表示時に潰れないようにする
        backgroundColor: Colors.transparent,
        builder: (context) => AiChatBottomSheet(memos: memos),
      );
    },
    backgroundColor: const Color(0xff4f46e5), // インディゴブルー
    foregroundColor: Colors.white,
    elevation: 4,
    icon: const Icon(Icons.smart_toy_outlined),
    label: const Text("AIに相談", style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// 簡易AIチャットのボトムシート本体
class AiChatBottomSheet extends StatefulWidget {
  final List<Memo> memos;
  // トップページから「自己分析まとめ」を直接指示したい場合の初期メッセージ
  final String? initialUserMessage;

  const AiChatBottomSheet({
    super.key,
    required this.memos,
    this.initialUserMessage,
  });

  @override
  State<AiChatBottomSheet> createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends State<AiChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Geminiのチャットセッションを保持する変数
  ChatSession? _chatSession;

  @override
  void initState() {
    super.initState();
    
    _messages.add({
      "role": "assistant",
      "content": "こんにちは！これまでの就活メモを元に、自己分析や企業選び、面接対策のお手伝いをします。何でも相談してくださいね！"
    });

    // トップページなどから初期指示（例：「自己分析のまとめをして」）がある場合
    if (widget.initialUserMessage != null) {
      _controller.text = widget.initialUserMessage!;
      // initState直後の発火を安定させるため少し遅らせて実行
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage();
      });
    }
  }

  /// 就活メモのリストをAIが理解できるテキスト形式（JSON等）に変換する
  String _convertMemosToContext() {
    if (widget.memos.isEmpty) {
      return "現在、ユーザーの就活メモは空です。";
    }
    final List<Map<String, dynamic>> memoData = widget.memos.map((m) => {
      "企業名": m.title,
      "選考状況": m.status,
      "カスタム項目": m.customFields,
    }).toList();
    return jsonEncode(memoData);
  }

  /// Gemini APIにメッセージを送信する
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
      _controller.clear();
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      
      // APIキーの存在チェック
      if (apiKey == null || apiKey.isEmpty) {
        setState(() {
          _messages.add({"role": "assistant", "content": "設定エラー: APIキーが読み込めませんでした。"});
          _isLoading = false;
        });
        return;
      }

      // チャットセッションが未作成の場合は初期化する
      if (_chatSession == null) {
        final model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
          // AIの役割（ペルソナ）とユーザーのメモデータをsystemInstructionに設定
          systemInstruction: Content.system(
            "あなたは優秀な就活キャリアアドバイザーです。ユーザーからこれまでの就活メモデータ（企業名、選考状況、メモ内容など）が共有されます。このデータを元に、自己分析の深堀り、強みの抽出、企業選びのアドバイスを、具体的かつ論理的に行ってください。時には『なぜそう感じましたか？』など、ユーザーの思考を促す逆質問を1つ混ぜると効果的です。\n\n【ユーザーの現在の就活状況データ】\n${_convertMemosToContext()}"
          ),
          generationConfig: GenerationConfig(temperature: 0.7),
        );

        // UI上の初期メッセージと整合性を合わせるため、履歴（history）に最初の挨拶をセットしてチャットを開始
        _chatSession = model.startChat(history: [
          Content.model([TextPart("こんにちは！これまでの就活メモを元に、自己分析や企業選び、面接対策のお手伝いをします。何でも相談してくださいね！")])
        ]);
      }

      // メッセージを送信（ChatSessionがこれまでの会話履歴を自動管理してくれます）
      final response = await _chatSession!.sendMessage(Content.text(text));
      final aiResponse = response.text ?? '回答を生成できませんでした。';

      setState(() {
        _messages.add({"role": "assistant", "content": aiResponse});
      });

    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "通信エラーが発生しました: $e"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // キーボードが表示された分だけ高さを底上げする
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 画面の75%の高さ
      margin: EdgeInsets.only(top: 60, bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 上部のつまみ（バー）
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xffcbd5e1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // タイトル
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xff4f46e5), size: 20),
                SizedBox(width: 8),
                Text(
                  "就活AIアシスタント",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xffe2e8f0)),
          
          // チャット履歴表示エリア
          Expanded(
                    child: TextField(
                      controller: _controller,
                      // 送信中（_isLoading）は入力も無効化するとより安心です
                      enabled: !_isLoading, 
                      decoration: InputDecoration(
                        hintText: _isLoading ? "AIの回答を待機中..." : "相談内容を入力...",
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xff94a3b8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xfff8fafc),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!_isLoading) _sendMessage();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    // 【重要】処理中（_isLoading）は onPressed を null にすることでボタンを無効化
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: Icon(
                      Icons.send, 
                      color: _isLoading ? Colors.grey : const Color(0xff4f46e5)
                    ),
                  ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff4f46e5)),
              ),
            ),

          // 入力エリア
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xffe2e8f0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "「志望動機を深掘りして」「自己分析の手伝いをして」など...",
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xff94a3b8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xfff8fafc),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Color(0xff4f46e5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}