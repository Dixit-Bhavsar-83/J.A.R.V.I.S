enum Sender { user, bot }

class ChatMessage {
  final String text;
  final Sender from;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.from,
    DateTime? at,
  }) : time = at ?? DateTime.now();

  Map<String, dynamic> toJson() =>
      {"t": text, "f": from.index, "d": time.millisecondsSinceEpoch};

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['t'],
        from: Sender.values[json['f']],
        at: DateTime.fromMillisecondsSinceEpoch(json['d']),
      );
}
