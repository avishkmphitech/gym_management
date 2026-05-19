import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/trainer_mock_data.dart';
import '../models/chat_message.dart';
import '../providers/member_identity.dart';
import '../providers/member_provider.dart';
import '../services/auth_service.dart';
import 'trainer_provider.dart';

/// Member is on the logged-in trainer's assigned roster (mock: [assignedMembers]).
bool isMemberOnTrainerRoster(String memberId) =>
    assignedMembers.any((m) => m.id == memberId);

class ChatState {
  const ChatState({
    required this.messagesByMemberId,
    required this.trainerReadCountByMemberId,
    required this.memberReadCountByMemberId,
  });

  final Map<String, List<ChatMessage>> messagesByMemberId;
  final Map<String, int> trainerReadCountByMemberId;
  final Map<String, int> memberReadCountByMemberId;

  factory ChatState.initial() {
    final now = DateTime.now();
    return ChatState(
      messagesByMemberId: {
        'm1': [
          ChatMessage(
            id: 'c1',
            memberId: 'm1',
            senderRole: ChatSenderRole.trainer,
            body: 'Hi Aarav — how are you feeling after yesterday\'s leg day?',
            sentAt: now.subtract(const Duration(hours: 20)),
          ),
          ChatMessage(
            id: 'c2',
            memberId: 'm1',
            senderRole: ChatSenderRole.member,
            body: 'A bit sore but good! Can we adjust squats this week?',
            sentAt: now.subtract(const Duration(hours: 19, minutes: 40)),
          ),
          ChatMessage(
            id: 'c3',
            memberId: 'm1',
            senderRole: ChatSenderRole.trainer,
            body: 'Yes — I\'ll lighten volume on Thursday. Keep protein up today.',
            sentAt: now.subtract(const Duration(hours: 18)),
          ),
        ],
        'm2': [
          ChatMessage(
            id: 'c4',
            memberId: 'm2',
            senderRole: ChatSenderRole.trainer,
            body: 'Meera, your yoga + strength week is ready in the app.',
            sentAt: now.subtract(const Duration(days: 1, hours: 3)),
          ),
        ],
        'm3': [
          ChatMessage(
            id: 'c5',
            memberId: 'm3',
            senderRole: ChatSenderRole.member,
            body: 'Can we move Friday\'s run to Saturday morning?',
            sentAt: now.subtract(const Duration(hours: 5)),
          ),
        ],
      },
      trainerReadCountByMemberId: {'m1': 3, 'm2': 1},
      memberReadCountByMemberId: {'m1': 2},
    );
  }

  List<ChatMessage> messagesFor(String memberId) =>
      List.unmodifiable(messagesByMemberId[memberId] ?? const []);

  ChatState copyWith({
    Map<String, List<ChatMessage>>? messagesByMemberId,
    Map<String, int>? trainerReadCountByMemberId,
    Map<String, int>? memberReadCountByMemberId,
  }) {
    return ChatState(
      messagesByMemberId: messagesByMemberId ?? this.messagesByMemberId,
      trainerReadCountByMemberId: trainerReadCountByMemberId ?? this.trainerReadCountByMemberId,
      memberReadCountByMemberId: memberReadCountByMemberId ?? this.memberReadCountByMemberId,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => ChatState.initial();

  List<ChatMessage> messagesFor(String memberId) => state.messagesFor(memberId);

  void send({
    required String memberId,
    required String body,
    required bool fromTrainer,
  }) {
    if (!isMemberOnTrainerRoster(memberId)) return;

    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    final list = List<ChatMessage>.from(state.messagesByMemberId[memberId] ?? []);
    list.add(
      ChatMessage(
        id: 'c_${DateTime.now().microsecondsSinceEpoch}',
        memberId: memberId,
        senderRole: fromTrainer ? ChatSenderRole.trainer : ChatSenderRole.member,
        body: trimmed,
        sentAt: DateTime.now(),
      ),
    );

    final trainerRead = Map<String, int>.from(state.trainerReadCountByMemberId);
    final memberRead = Map<String, int>.from(state.memberReadCountByMemberId);
    if (fromTrainer) {
      trainerRead[memberId] = list.length;
    } else {
      memberRead[memberId] = list.length;
    }

    state = state.copyWith(
      messagesByMemberId: {...state.messagesByMemberId, memberId: list},
      trainerReadCountByMemberId: trainerRead,
      memberReadCountByMemberId: memberRead,
    );
  }

  void markRead(String memberId, {required bool viewerIsTrainer}) {
    if (!isMemberOnTrainerRoster(memberId)) return;

    final count = state.messagesFor(memberId).length;
    if (viewerIsTrainer) {
      state = state.copyWith(
        trainerReadCountByMemberId: {
          ...state.trainerReadCountByMemberId,
          memberId: count,
        },
      );
    } else {
      state = state.copyWith(
        memberReadCountByMemberId: {
          ...state.memberReadCountByMemberId,
          memberId: count,
        },
      );
    }
  }

  int unreadForTrainer(String memberId) {
    final msgs = state.messagesFor(memberId);
    final read = state.trainerReadCountByMemberId[memberId] ?? 0;
    return msgs.skip(read).where((m) => m.isFromMember).length;
  }

  int unreadForMember(String memberId) {
    final msgs = state.messagesFor(memberId);
    final read = state.memberReadCountByMemberId[memberId] ?? 0;
    return msgs.skip(read).where((m) => m.isFromTrainer).length;
  }

  int get totalUnreadForTrainer {
    var n = 0;
    for (final m in assignedMembers) {
      n += unreadForTrainer(m.id);
    }
    return n;
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

/// Trainer may open chat only for members on their assigned roster.
final trainerCanChatWithMemberProvider = Provider.family<bool, String>((ref, memberId) {
  return ref.watch(trainerProvider).memberById(memberId) != null;
});

/// Member may chat only with their assigned trainer (roster match + own thread).
final memberCanUseChatProvider = Provider<bool>((ref) {
  final user = ref.watch(authServiceProvider);
  if (user?.role != 'MEMBER') return false;
  final assigned = ref.watch(memberAssignedMemberProvider);
  if (assigned == null) return false;
  final memberId = ref.watch(memberTrainerIdProvider);
  if (memberId != assigned.id || !isMemberOnTrainerRoster(memberId)) return false;
  return user!.name.toLowerCase().trim() == assigned.name.toLowerCase().trim();
});

/// Member may view/send only on their own assigned thread id.
final memberCanAccessChatThreadProvider = Provider.family<bool, String>((ref, threadMemberId) {
  if (!ref.watch(memberCanUseChatProvider)) return false;
  return ref.watch(memberTrainerIdProvider) == threadMemberId;
});

final chatMessagesProvider = Provider.family<List<ChatMessage>, String>((ref, memberId) {
  final user = ref.watch(authServiceProvider);
  final allowed = user?.role == 'TRAINER'
      ? ref.watch(trainerCanChatWithMemberProvider(memberId))
      : ref.watch(memberCanAccessChatThreadProvider(memberId));
  if (!allowed) return const [];
  return ref.watch(chatProvider).messagesFor(memberId);
});

final chatThreadSummariesForTrainerProvider = Provider<List<ChatThreadSummary>>((ref) {
  final chat = ref.watch(chatProvider);
  final notifier = ref.read(chatProvider.notifier);

  return assignedMembers.map((m) {
    final msgs = chat.messagesFor(m.id);
    final last = msgs.isNotEmpty ? msgs.last : null;
    return ChatThreadSummary(
      memberId: m.id,
      peerName: m.name,
      lastPreview: last?.body ?? 'No messages yet',
      lastSentAt: last?.sentAt,
      unreadCount: notifier.unreadForTrainer(m.id),
    );
  }).toList()
    ..sort((a, b) {
      final at = a.lastSentAt;
      final bt = b.lastSentAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
});

final memberChatUnreadProvider = Provider<int>((ref) {
  ref.watch(chatProvider);
  final memberId = ref.watch(memberTrainerIdProvider);
  return ref.read(chatProvider.notifier).unreadForMember(memberId);
});

final trainerChatUnreadProvider = Provider<int>((ref) {
  ref.watch(chatProvider);
  return ref.read(chatProvider.notifier).totalUnreadForTrainer;
});
