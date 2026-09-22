/// Business-level constants. Keep configuration out of magic numbers
/// scattered across features.
abstract class AppConstants {
  /// Default production ratio: 1 finished saree = 1 saree + 1 lace + 1 blouse.
  /// Used only to auto-fill challan item quantities; always editable.
  static const double defaultLaceRatio = 1.0;
  static const double defaultBlouseRatio = 1.0;

  static const String challanNumberPrefix = 'CH';

  /// Firestore pagination page size for list/report screens.
  static const int defaultPageSize = 25;
}
