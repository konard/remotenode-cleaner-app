class FileSizeFormatter {
  static String format(int bytes) {
    if (bytes < 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    if (size == size.roundToDouble()) {
      return '${size.toInt()} ${suffixes[i]}';
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  static String formatShort(int bytes) {
    if (bytes < 0) return '0';

    const suffixes = ['B', 'K', 'M', 'G', 'T'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    if (i == 0) {
      return '${size.toInt()}${suffixes[i]}';
    }
    if (size == size.roundToDouble()) {
      return '${size.toInt()}${suffixes[i]}';
    }
    return '${size.toStringAsFixed(1)}${suffixes[i]}';
  }

  static int parseSize(String sizeStr) {
    final regex = RegExp(r'^([\d.]+)\s*(B|KB|MB|GB|TB)$', caseSensitive: false);
    final match = regex.firstMatch(sizeStr.trim());

    if (match == null) return 0;

    final value = double.tryParse(match.group(1)!) ?? 0;
    final suffix = match.group(2)!.toUpperCase();

    const multipliers = {
      'B': 1,
      'KB': 1024,
      'MB': 1024 * 1024,
      'GB': 1024 * 1024 * 1024,
      'TB': 1024 * 1024 * 1024 * 1024,
    };

    return (value * (multipliers[suffix] ?? 1)).toInt();
  }
}
