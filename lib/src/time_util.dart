class TimeUtil {
  static String getTimestamp() {
    return DateTime.now()
        .toUtc()
        .toString()
        .substring(0, 14)
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll(' ', '');
  }
}
