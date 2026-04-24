// lib/features/chat/models/chat_preview.dart

class ChatPreview {
  final String id;
  final String name;
  final String avatarInitial;
  final String avatarColor;   // hex string e.g. '0xFF58DAD0'
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String destination;   // e.g. 'Goa · May 12–16'
  final bool isOnline;

  const ChatPreview({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.avatarColor,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    required this.destination,
    this.isOnline = false,
  });
}

// ── Mock data ─────────────────────────────────────────────────────────────────
const mockChatPreviews = [
  ChatPreview(
    id: 'rahul',
    name: 'Rahul',
    avatarInitial: 'R',
    avatarColor: '0xFF58DAD0',
    lastMessage: 'I was thinking we hit up Curlies on the first night 🍹',
    time: '5:03 PM',
    unreadCount: 2,
    destination: 'Goa · May 12–16',
    isOnline: true,
  ),
  ChatPreview(
    id: 'priya',
    name: 'Priya',
    avatarInitial: 'P',
    avatarColor: '0xFFB57BFF',
    lastMessage: 'Spiti sounds amazing, I\'m in! ❄️',
    time: 'Yesterday',
    unreadCount: 0,
    destination: 'Spiti Valley · May 20–26',
    isOnline: false,
  ),
  ChatPreview(
    id: 'karan',
    name: 'Karan',
    avatarInitial: 'K',
    avatarColor: '0xFFF7B84E',
    lastMessage: 'Can we push the check-in to 3 PM?',
    time: 'Mon',
    unreadCount: 1,
    destination: 'Manali · Jun 1–5',
    isOnline: true,
  ),
  ChatPreview(
    id: 'simran',
    name: 'Simran',
    avatarInitial: 'S',
    avatarColor: '0xFFFF7E7E',
    lastMessage: 'Added Rishikesh rafting to our plan ✅',
    time: 'Sun',
    unreadCount: 0,
    destination: 'Rishikesh · May 30',
    isOnline: false,
  ),
  ChatPreview(
    id: 'arjun',
    name: 'Arjun',
    avatarInitial: 'A',
    avatarColor: '0xFF4EC9F7',
    lastMessage: 'See you at the hostel lobby 🙌',
    time: 'Fri',
    unreadCount: 0,
    destination: 'Kasol · Jun 10–14',
    isOnline: false,
  ),
];