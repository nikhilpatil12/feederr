String timeAgo(int timestampInMs) {
  final now = DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(timestampInMs * 1000);
  final difference = now.difference(then);

  final inMinutes =
      difference.inMinutes % 60; // Use max to avoid negative values
  final inHours = difference.inHours % 24;
  final inDays = difference.inDays;

  if (inDays > 0) {
    return inDays == 1 ? "$inDays day ago" : "$inDays days ago";
  } else if (inHours > 0) {
    return inHours == 1 ? "$inHours hour ago" : "$inHours hours ago";
  } else {
    return inMinutes == 1 ? "$inMinutes minute ago" : "$inMinutes minutes ago";
  }
}

String getTag(String rawTag) {
  List<String> splitted = rawTag.split("/");
  return splitted.last;
}
