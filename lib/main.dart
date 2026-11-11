import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/message_log.dart';

class ChatState {
  const ChatState(
      {this.signedIn = false, this.messages = const [], this.error});

  final bool signedIn;
  final List<ChatMessage> messages;
  final String? error;

  ChatState copyWith({
    bool? signedIn,
    List<ChatMessage>? messages,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      signedIn: signedIn ?? this.signedIn,
      messages: messages ?? this.messages,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController() : super(const ChatState());

  final _log = MessageLog();

  void signIn(String email, String password) {
    if (email.trim() == 'lea@chatsphere.dev' && password == 'demo1234') {
      state = state.copyWith(signedIn: true, clearError: true);
    } else {
      state = state.copyWith(error: 'Use the demo profile on this screen.');
    }
  }

  void send(String body) {
    final text = body.trim();
    if (text.isEmpty) return;
    final message = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: 'studio',
      body: text,
      sentAt: DateTime.now(),
      delivery: Delivery.pending,
    );
    state = state.copyWith(messages: _log.merge(state.messages, [message]));
  }

  void markSent() {
    state = state.copyWith(
      messages: [
        for (final message in state.messages)
          if (message.delivery == Delivery.pending)
            message.copyWith(delivery: Delivery.sent)
          else
            message,
      ],
    );
  }
}

final chatProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) => ChatController());

void main() {
  runApp(const ProviderScope(child: ChatSphereApp()));
}

class ChatSphereApp extends StatelessWidget {
  const ChatSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C4AB6),
          primary: const Color(0xFF6C4AB6),
          background: const Color(0xFFF6F4F8),
        ),
      ),
      home: const ChatGate(),
    );
  }
}

class ChatGate extends ConsumerWidget {
  const ChatGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(chatProvider).signedIn;
    return signedIn ? const ThreadPage() : const SignInPage();
  }
}

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _email = TextEditingController(text: 'lea@chatsphere.dev');
  final _password = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(chatProvider).error;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('ChatSphere',
                style: Theme.of(context).textTheme.headlineMedium),
            const Text(
                'Local thread demo. Messages are not end-to-end encrypted.'),
            const SizedBox(height: 16),
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (error != null) Text(error),
            FilledButton(
              onPressed: () => ref
                  .read(chatProvider.notifier)
                  .signIn(_email.text, _password.text),
              child: const Text('Open thread'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThreadPage extends ConsumerStatefulWidget {
  const ThreadPage({super.key});

  @override
  ConsumerState<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends ConsumerState<ThreadPage> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider).messages;
    return Scaffold(
      appBar: AppBar(title: const Text('Studio')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Say hello. Outgoing notes start as pending.'))
                : ListView(
                    children: [
                      for (final message in messages)
                        ListTile(
                          title: Text(message.body),
                          subtitle: Text(message.delivery.name),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    decoration: const InputDecoration(hintText: 'Message'),
                  ),
                ),
                IconButton(
                  tooltip: 'Send',
                  onPressed: () {
                    ref.read(chatProvider.notifier).send(_text.text);
                    _text.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
                IconButton(
                  tooltip: 'Mark sent',
                  onPressed: () => ref.read(chatProvider.notifier).markSent(),
                  icon: const Icon(Icons.done_all),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
