class EscPosCharsetEncoding {
  late String _charsetName;
  late List<int> _charsetCommand;

  /// Create new instance of EscPosCharsetEncoding.
  ///
  /// @param charsetName Name of charset encoding (Ex: windows-1252)
  /// @param escPosCharsetId Id of charset encoding for your printer (Ex: 16)

  EscPosCharsetEncoding(String charsetName, int escPosCharsetId) {
    _charsetName = charsetName;
    _charsetCommand = [0x1B, 0x74, escPosCharsetId];
  }

  List<int> get getCommand => _charsetCommand;
  String get getName => _charsetName;
}
