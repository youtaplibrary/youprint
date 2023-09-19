import 'dart:math' as math;

class BatchPrintOptions {
  const BatchPrintOptions(
    int iterations, {
    this.delay = Duration.zero,
    this.feedCount = 0,
    this.useCut = false,
  })  : _iterations = iterations,
        _n = null;

  const BatchPrintOptions.perNContent(
    int n, {
    this.delay = Duration.zero,
    this.feedCount = 0,
    this.useCut = false,
  })  : _n = n,
        _iterations = null;

  static const BatchPrintOptions full = BatchPrintOptions(1);

  final int? _iterations;

  final int? _n;

  /// Delay between each print
  final Duration delay;

  /// Feed count for each print
  final int feedCount;

  /// Whether each print should be appended cut command at the end of content
  final bool useCut;

  /// Returns an iteration generator that generates 3 values (in order):
  /// - start of batch (int)
  /// - end of batch (int)
  /// - whether the batch is the last one (bool)
  Iterable<List<Object>> getStartEnd(int contentLength) sync* {
    if (contentLength == 0) {
      yield const <Object>[0, 0, true];
      return;
    }
    final int iterations = _iterations ?? (contentLength / _n!).ceil();
    final int subListLength = _n ?? (contentLength / iterations).ceil();
    int start = 0;
    int end = 0;
    for (int i = 0; i < iterations; i++) {
      end += subListLength;
      end = math.min(end, contentLength);
      yield <Object>[start, end, end == contentLength];
      start = end;
    }
  }
}
