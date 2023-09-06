class EscPosEncodingException implements Exception {
  final String errorMessage;
  const EscPosEncodingException(this.errorMessage);

  @override
  String toString() => 'EscPosEncodingException: $errorMessage';
}
