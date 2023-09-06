class EscPosParserException implements Exception {
  final String errorMessage;
  const EscPosParserException(this.errorMessage);

  @override
  String toString() => 'EscPosParserException: $errorMessage';
}
