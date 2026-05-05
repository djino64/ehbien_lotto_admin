class Validators {
  Validators._();
  static String? required(String? v, {String label = 'Ce champ'}) =>
      (v == null || v.trim().isEmpty) ? '$label est requis.' : null;
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Le numéro est requis.';
    if (!RegExp(r'^\+?[\d\s\-]{8,15}$').hasMatch(v.trim())) return 'Numéro invalide.';
    return null;
  }
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(v.trim())) return 'Email invalide.';
    return null;
  }
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis.';
    if (v.length < 6) return 'Minimum 6 caractères.';
    return null;
  }
  static String? positiveAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Montant requis.';
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null) return 'Montant invalide.';
    if (n <= 0)    return 'Le montant doit être positif.';
    return null;
  }
}
