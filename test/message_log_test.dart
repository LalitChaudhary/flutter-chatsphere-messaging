import 'package:chatsphere/domain/message_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final log = MessageLog();
  final first = ChatMessage(
    id: 'm1',
    conversationId: 'studio',
    body: 'hello',
    sentAt: DateTime.utc(2026, 1, 1, 1),
    delivery: Delivery.sent,
  );
  final duplicate = ChatMessage(
    id: 'm1',
    conversationId: 'studio',
    body: 'hello',
    sentAt: DateTime.utc(2026, 1, 1, 1),
    delivery: Delivery.read,
  );
  final later = ChatMessage(
    id: 'm2',
    conversationId: 'studio',
    body: 'next',
    sentAt: DateTime.utc(2026, 1, 1, 2),
    delivery: Delivery.pending,
  );

  test('duplicate ids keep the stronger receipt and order by time', () {
    final merged = log.merge([later], [first, duplicate]);
    expect(merged.map((m) => m.id).toList(), ['m1', 'm2']);
    expect(merged.first.delivery, Delivery.read);
  });

  test('a weaker receipt does not downgrade', () {
    final merged = log.merge([duplicate], [first]);
    expect(merged.single.delivery, Delivery.read);
  });
}
