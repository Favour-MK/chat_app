class Conversation {
  final int id;
  final String? name;

  Conversation({required this.id, this.name});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['conversation_id'],
      name: json['conversation_name'],
    );
  }
}
