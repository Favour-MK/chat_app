class Message {
  final int id;
  final int senderId;
  final String text;
  final int conversationId;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.conversationId,
  });

  // Converts the JSON from Python into a Dart object safely
  factory Message.fromJson(Map<String, dynamic> json) {
    // 1. Print the raw data so we can see exactly what Python sent us in the console!
    print("RAW JSON RECEIVED: $json");

    return Message(
      // 2. The '?? 0' tells Dart: "If this key is missing or null, just use 0 instead of crashing"
      id: json['message_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      text: json['message_text'] ?? json['text'] ?? '',
      conversationId: json['conversation_id'] ?? 0,
    );
  }
}
