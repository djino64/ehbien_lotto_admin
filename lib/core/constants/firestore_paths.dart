class FirestorePaths {
  FirestorePaths._();
  static const String users          = 'users';
  static const String agents         = 'agents';
  static const String succursales    = 'succursales';
  static const String tirages        = 'tirages';
  static const String tickets        = 'tickets';
  static const String blockedNumbers = 'blocked_numbers';
  static const String limits         = 'limits';
  static const String commissions    = 'commissions';
  static const String notifications  = 'notifications';
  static const String settings       = 'settings';
  static const String reports        = 'reports';
  static const String auditLogs      = 'audit_logs';

  static String tirageResults(String tirageId) => '$tirages/$tirageId/results';
  static String ticketItems(String ticketId)   => '$tickets/$ticketId/items';
  static String userDoc(String uid)            => '$users/$uid';
  static String agentDoc(String id)            => '$agents/$id';
  static String succursaleDoc(String id)       => '$succursales/$id';
  static String tirageDoc(String id)           => '$tirages/$id';
  static String ticketDoc(String id)           => '$tickets/$id';
  static String settingDoc(String key)         => '$settings/$key';
}
