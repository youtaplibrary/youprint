class EscPosBarcodeException implements Exception {
  final String errorMessage;
  const EscPosBarcodeException(this.errorMessage);

  @override
  String toString() => 'EscPosBarcodeException: $errorMessage';
}
