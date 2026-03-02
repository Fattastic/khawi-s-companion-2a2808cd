import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/chat/domain/message.dart';

class ChatState {
  final List<TripMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = true,
    this.error,
  });

  ChatState copyWith({
    List<TripMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatController extends AutoDisposeFamilyNotifier<ChatState, String> {
  late final String _tripId;

  @override
  ChatState build(String arg) {
    _tripId = arg;
    _initSubscription();
    return ChatState();
  }

  void _initSubscription() {
    final sub = ref.watch(chatRepoProvider).watchMessages(_tripId).listen(
      (messages) {
        state = state.copyWith(messages: messages, isLoading: false);
      },
      onError: (Object e) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      },
    );
    ref.onDispose(() => sub.cancel());
  }

  Future<void> sendMessage(String text, String senderId) async {
    try {
      await ref.read(chatRepoProvider).sendMessage(
            tripId: _tripId,
            senderId: senderId,
            body: text,
          );
    } catch (e) {
      state = state.copyWith(error: "Failed to send message: $e");
    }
  }
}

final chatControllerProvider =
    NotifierProvider.autoDispose.family<ChatController, ChatState, String>(
  ChatController.new,
);
