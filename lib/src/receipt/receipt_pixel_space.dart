class ReceiptPixelSpace {
  const ReceiptPixelSpace({
    required this.pixels,
  }) : assert(pixels > 0);

  final int pixels;

  String get content => '[L]\n';
}
