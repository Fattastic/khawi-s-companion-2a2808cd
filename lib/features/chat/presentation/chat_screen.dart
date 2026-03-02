import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/chat/domain/chat_assistant_suggestions.dart';
import 'package:khawi_flutter/features/chat/domain/message.dart';
import 'package:khawi_flutter/features/chat/domain/quick_reply_templates.dart';
import 'package:khawi_flutter/features/chat/domain/voice_note_message.dart';
import 'controllers/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ChatScreen({super.key, required this.tripId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _recordingTicker;
  DateTime? _recordingStartedAt;
  int _recordingSeconds = 0;

  bool get _isRecording => _recordingStartedAt != null;

  @override
  void initState() {
    super.initState();
    // Listen once to avoid stacking listeners on rebuilds.
    ref.listen(chatControllerProvider(widget.tripId), (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.tripId));
    final currentUserId = ref.watch(userIdProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trip Chat",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "AI Moderation Active",
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          _buildInputArea(currentUserId, isRtl),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(TripMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF3F0081) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(20),
              ),
              boxShadow: isMe
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 5,
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.body,
                  style: GoogleFonts.inter(
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
                if (message.moderationStatus == 'warning')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "⚠️ Policy Warning",
                      style: GoogleFonts.inter(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(message.createdAt),
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(String? userId, bool isRtl) {
    final replies = quickReplyTemplates(isRtl: isRtl);
    final state = ref.watch(chatControllerProvider(widget.tripId));
    final lastIncomingMessage =
        state.messages.isEmpty ? null : state.messages.last.body;
    final assistantSuggestions = buildChatAssistantSuggestions(
      isRtl: isRtl,
      draft: _textController.text,
      lastIncomingMessage: lastIncomingMessage,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isRtl
                        ? 'جاري تسجيل رسالة صوتية ${formatVoiceNoteDuration(_recordingSeconds)}'
                        : 'Recording voice message ${formatVoiceNoteDuration(_recordingSeconds)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: replies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final text = replies[index];
                return ActionChip(
                  label: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: userId == null
                      ? null
                      : () {
                          _textController.text = text;
                          _sendMessage(userId);
                        },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: assistantSuggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final text = assistantSuggestions[index];
                return ActionChip(
                  avatar: const Icon(Icons.smart_toy_outlined, size: 16),
                  label: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: userId == null
                      ? null
                      : () {
                          _textController.text = text;
                          _sendMessage(userId);
                        },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: isRtl ? 'اكتب رسالة...' : 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _sendMessage(userId),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: const Color(0xFF3F0081),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  tooltip: isRtl ? 'إرسال' : 'Send message',
                  onPressed: () => _sendMessage(userId),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: _isRecording ? Colors.red : Colors.black87,
                child: IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: _isRecording
                      ? (isRtl ? 'إيقاف التسجيل' : 'Stop recording')
                      : (isRtl ? 'تسجيل رسالة صوتية' : 'Record voice note'),
                  onPressed: userId == null
                      ? null
                      : () => _toggleVoiceRecording(userId, isRtl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleVoiceRecording(String userId, bool isRtl) {
    if (_isRecording) {
      _recordingTicker?.cancel();
      final seconds = _recordingSeconds;
      _recordingStartedAt = null;
      _recordingSeconds = 0;
      setState(() {});

      final body = formatVoiceNoteMessage(seconds: seconds, isRtl: isRtl);
      ref.read(chatControllerProvider(widget.tripId).notifier).sendMessage(
            body,
            userId,
          );
      _scrollToBottom();
      return;
    }

    _recordingStartedAt = DateTime.now();
    _recordingSeconds = 0;
    _recordingTicker?.cancel();
    _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _recordingStartedAt == null) return;
      setState(() {
        _recordingSeconds =
            DateTime.now().difference(_recordingStartedAt!).inSeconds;
      });
    });
    setState(() {});
  }

  void _sendMessage(String? userId) {
    if (_textController.text.trim().isEmpty || userId == null) return;
    ref
        .read(chatControllerProvider(widget.tripId).notifier)
        .sendMessage(_textController.text.trim(), userId);
    _textController.clear();
    _scrollToBottom();
  }

  String _formatTimestamp(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
