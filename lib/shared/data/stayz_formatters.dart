class StayzFormatters {
  const StayzFormatters._();

  static String compactVnd(num value) {
    if (value >= 1000000) {
      final millions = value / 1000000;
      return '₫${millions.toStringAsFixed(millions % 1 == 0 ? 0 : 1)}M';
    }

    if (value >= 1000) {
      return '₫${(value / 1000).round()}K';
    }

    return '₫$value';
  }

  static String fullVnd(num value) {
    final text = value.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '₫$buffer';
  }

  static String shortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  static int nightsBetween(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  static num bookingTotal({
    required num pricePerNight,
    required int nights,
    required int roomQuantity,
  }) {
    return pricePerNight * nights * roomQuantity;
  }
}
