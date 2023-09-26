extension StringExtension on String {
  List<String> splitByLength(int length) {
    List<String> pieces = [];
    if (!contains(' ')) {
      for (int i = 0; i < this.length; i += length) {
        int offset = i + length;
        pieces.add(substring(i, offset >= this.length ? this.length : offset));
      }
      return pieces;
    }

    List<String> words = split(' ');
    String currentLine = '';
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (currentLine.isEmpty) {
        currentLine = word;
      } else {
        String testLine = '$currentLine $word';
        if (testLine.length <= length) {
          currentLine = testLine;
        } else {
          pieces.add(currentLine);
          currentLine = word;
        }
      }
    }

    if (currentLine.isNotEmpty) {
      pieces.add(currentLine);
    }

    return pieces;
  }
}
