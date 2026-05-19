/// One message in a member ↔ trainer thread (keyed by roster member id, e.g. `m1`).
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.memberId,
    required this.senderRole,
    required this.body,
    required this.sentAt,
  });

  final String id;
  final String memberId;
  final ChatSenderRole senderRole;
  final String body;
  final DateTime sentAt;

  bool get isFromTrainer => senderRole == ChatSenderRole.trainer;
  bool get isFromMember => senderRole == ChatSenderRole.member;
}

enum ChatSenderRole { member, trainer }

/// Trainer inbox row — one thread per assigned member.
class ChatThreadSummary {
  const ChatThreadSummary({
    required this.memberId,
    required this.peerName,
    required this.lastPreview,
    required this.lastSentAt,
    required this.unreadCount,
  });

  final String memberId;
  final String peerName;
  final String lastPreview;
  final DateTime? lastSentAt;
  final int unreadCount;
}
