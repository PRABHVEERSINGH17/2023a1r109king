import 'package:flutter/material.dart';

import '../models/faq.dart';
import '../services/chatbot_service.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.college, required this.chatbot});

  final CollegeData college;
  final ChatbotService chatbot;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _loading = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(
        text:
            "Hello! I'm your college FAQ assistant. Ask about admissions, fees, exams, hostel, placements, and more.",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _loading) return;

    setState(() {
      _loading = true;
      _suggestions = [];
      _messages.add(_ChatMessage(text: trimmed, isUser: true));
      _controller.clear();
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final result = widget.chatbot.chat(trimmed);

    setState(() {
      _loading = false;
      _messages.add(
        _ChatMessage(
          text: result.answer,
          isUser: false,
          matchedQuestion: result.matchedQuestion,
          category: result.category,
          confidence: result.confidence,
        ),
      );
      _suggestions = result.suggestions;
    });
    _scrollToBottom();
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(
          const _ChatMessage(
            text: 'Chat cleared. How can I help you today?',
            isUser: false,
          ),
        );
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FAQ Chatbot', style: TextStyle(fontSize: 18)),
            Text(
              widget.college.collegeName,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_suggestions.isNotEmpty) _buildSuggestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('🎓', style: TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.college.collegeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text('AI FAQ Assistant', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('CATEGORIES', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...widget.college.categories.map((cat) {
              return ListTile(
                dense: true,
                leading: Text(cat.icon, style: const TextStyle(fontSize: 20)),
                title: Text(cat.name, style: const TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  if (cat.faqs.isNotEmpty) {
                    _sendMessage(cat.faqs.first.question);
                  }
                },
              );
            }),
            const Divider(height: 32),
            Text('QUICK QUESTIONS', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...widget.college.categories
                .expand((c) => c.faqs)
                .take(6)
                .map(
                  (faq) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        foregroundColor: Colors.grey.shade300,
                        side: BorderSide(color: Colors.grey.shade700),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _sendMessage(faq.question);
                      },
                      child: Text(faq.question, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isUser) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.surfaceLight,
                child: const Text('🤖', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isUser ? AppTheme.primary : AppTheme.botBubble,
                  borderRadius: BorderRadius.circular(14),
                  border: msg.isUser ? null : Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(msg.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                    if (!msg.isUser && msg.matchedQuestion != null) ...[
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade700, height: 1),
                      const SizedBox(height: 6),
                      Text(
                        'Matched: ${msg.matchedQuestion}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                      if (msg.category != null)
                        Text(
                          'Category: ${msg.category} • ${(msg.confidence * 100).round()}% confidence',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            if (msg.isUser) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary,
                child: Text('👤', style: TextStyle(fontSize: 14)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.surfaceLight,
            child: const Text('🤖', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.botBubble,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: const SizedBox(
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Dot(),
                  _Dot(delay: 150),
                  _Dot(delay: 300),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _suggestions.map((q) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(q, style: const TextStyle(fontSize: 11)),
              backgroundColor: AppTheme.surfaceLight,
              side: BorderSide(color: Colors.grey.shade700),
              onPressed: () => _sendMessage(q),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your question...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            onPressed: _loading ? null : () => _sendMessage(_controller.text),
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.matchedQuestion,
    this.category,
    this.confidence = 0,
  });

  final String text;
  final bool isUser;
  final String? matchedQuestion;
  final String? category;
  final double confidence;
}

class _Dot extends StatefulWidget {
  const _Dot({this.delay = 0});

  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * _controller.value),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
