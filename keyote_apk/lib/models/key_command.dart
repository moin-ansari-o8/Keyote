class KeyCommand {
  final String key;
  final bool ctrl;
  final bool shift;
  final bool alt;

  const KeyCommand({
    required this.key,
    this.ctrl = false,
    this.shift = false,
    this.alt = false,
  });

  Map<String, dynamic> toJson() {
    return {'key': key, 'ctrl': ctrl, 'shift': shift, 'alt': alt};
  }
}
