enum Delivery { pending, sent, delivered, read, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.sentAt,
    required this.delivery,
  });

  final String id;
  final String conversationId;
  final String body;
  final DateTime sentAt;
  final Delivery delivery;

  ChatMessage copyWith({String? body, Delivery? delivery}) => ChatMessage(
        id: id,
        conversationId: conversationId,
        body: body ?? this.body,
        sentAt: sentAt,
        delivery: delivery ?? this.delivery,
      );
}

class MessageLog {
  List<ChatMessage> merge(
      List<ChatMessage> current, List<ChatMessage> incoming) {
    final byId = <String, ChatMessage>{
      for (final message in current) message.id: message
    };
    for (final message in incoming) {
      final previous = byId[message.id];
      if (previous == null) {
        byId[message.id] = message;
      } else {
        final delivery = message.delivery.index >= previous.delivery.index
            ? message.delivery
            : previous.delivery;
        byId[message.id] =
            previous.copyWith(body: message.body, delivery: delivery);
      }
    }
    final list = byId.values.toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }
}
