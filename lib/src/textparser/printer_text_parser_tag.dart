import 'dart:collection';

class PrinterTextParserTag {
  String _tagName = "";
  HashMap<String, String> attributes = HashMap<String, String>();
  int _length = 0;
  bool _isCloseTag = false;

  PrinterTextParserTag(String tag) {
    tag = tag.trim();

    if (!tag.startsWith('<') || !tag.endsWith('>')) {
      return;
    }

    _length = tag.length;
    int openTagIndex = tag.indexOf('<'),
        closeTagIndex = tag.indexOf('>'),
        nextSpaceIndex = tag.indexOf(' ');

    if (nextSpaceIndex != -1 && nextSpaceIndex < closeTagIndex) {
      _tagName = tag.substring(openTagIndex + 1, nextSpaceIndex).toLowerCase();

      String attributeString = tag.substring(nextSpaceIndex, closeTagIndex).trim();
      while (attributeString.contains("='")) {
        int egalPos = attributeString.indexOf("='"),
            endPos = attributeString.indexOf("'", egalPos + 2);

        String attributeName = attributeString.substring(0, egalPos);
        String attributeValue = attributeString.substring(egalPos + 2, endPos);

        if (attributeName.isNotEmpty) {
          attributes[attributeName] = attributeValue;
        }

        attributeString = attributeString.substring(endPos + 1).trim();
      }
    } else {
      _tagName = tag.substring(openTagIndex + 1, closeTagIndex).toLowerCase();
    }

    if (_tagName.startsWith('/')) {
      _tagName = _tagName.substring(1);
      _isCloseTag = true;
    }
  }

  String get getTagName => _tagName;

  HashMap<String, String> get getAttributes => attributes;

  String? getAttribute(String key) => attributes[key];

  bool hasAttribute(String key) => attributes.containsKey(key);

  int get getLength => _length;

  bool get isCloseTag => _isCloseTag;
}
