/// Location validators
class LocationValidator {
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;

  static bool isValidLatitude(double lat) =>
      lat >= minLatitude && lat <= maxLatitude && !lat.isNaN;

  static bool isValidLongitude(double lng) =>
      lng >= minLongitude && lng <= maxLongitude && !lng.isNaN;

  static bool isValidLocation(double lat, double lng) =>
      isValidLatitude(lat) && isValidLongitude(lng);

  static String? validateLatitude(double? lat) {
    if (lat == null) return 'Latitude required';
    if (lat.isNaN) return 'Invalid latitude (NaN)';
    if (!isValidLatitude(lat)) return 'Latitude must be between -90 and 90';
    return null;
  }

  static String? validateLongitude(double? lng) {
    if (lng == null) return 'Longitude required';
    if (lng.isNaN) return 'Invalid longitude (NaN)';
    if (!isValidLongitude(lng)) return 'Longitude must be between -180 and 180';
    return null;
  }
}

/// Phone number validator
class PhoneValidator {
  static bool isValidSaudiPhone(String phone) {
    // Saudi phone: +966501234567 or 0501234567
    final pattern = RegExp(r'^(\+966|0)[0-9]{9}$');
    return pattern.hasMatch(phone.replaceAll(' ', ''));
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Phone required';
    if (!isValidSaudiPhone(phone)) {
      return 'Invalid phone format (+966 or 0)';
    }
    return null;
  }

  /// Normalize phone to +966 format
  static String normalize(String phone) {
    phone = phone.replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('0')) {
      return '+966${phone.substring(1)}';
    }
    return phone;
  }
}
