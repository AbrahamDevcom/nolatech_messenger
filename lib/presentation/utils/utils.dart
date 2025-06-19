String extractOtherUserId(String chatId, String currentUserId) {
  final parts = chatId.split('_');
  if (parts.length != 2) return '';

  return parts[0] == currentUserId ? parts[1] : parts[0];
}
