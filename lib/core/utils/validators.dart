class Validators {
  Validators._();

  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _digits = RegExp(r'^\d+$');

  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? mobile(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Mobile number is required';
    if (!_digits.hasMatch(value)) return 'Digits only';
    if (value.length != 10) return 'Enter exactly 10 digits';
    return null;
  }

  /// Optional: only validated when something is entered.
  static String? optionalEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null;
    return _email.hasMatch(value) ? null : 'Enter a valid email';
  }

  /// Visitor ids are server generated (MockAPI uses numeric strings, but
  /// accept alphanumeric ids such as VIS001 too).
  static bool isValidVisitorId(String? v) =>
      v != null && RegExp(r'^[A-Za-z0-9_-]{1,40}$').hasMatch(v.trim());
}
