class EscPosConnectionException implements Exception {
  final String errorMessage;
  const EscPosConnectionException(this.errorMessage);

  @override
  String toString() => 'EscPosConnectionException: $errorMessage';
}
