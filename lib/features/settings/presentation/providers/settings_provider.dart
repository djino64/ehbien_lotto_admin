// lib/features/settings/presentation/providers/settings_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:ehbien_lotto_admin/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/settings/data/repositories/app_settings_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/entities/app_setting_entity.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final settingsDatasourceProvider =
    Provider<SettingsRemoteDatasource>((ref) {
  return SettingsRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final settingsRepositoryProvider =
    Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepositoryImpl(
    ref.watch(settingsDatasourceProvider),
  );
});

// ── Stream tous les paramètres ────────────────────────────────
final settingsStreamProvider =
    StreamProvider<List<AppSettingEntity>>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchAllSettings();
});

// ── Paramètre par clé ─────────────────────────────────────────
final settingByKeyProvider =
    Provider.family<AppSettingEntity?, String>((ref, key) {
  final all =
      ref.watch(settingsStreamProvider).valueOrNull ?? [];
  try {
    return all.firstWhere((s) => s.id == key);
  } catch (_) {
    return null;
  }
});

// ── Clés prédéfinies ──────────────────────────────────────────
class SettingKeys {
  SettingKeys._();

  // Multiplicateurs de gains
  static const String multiplicateurBorlette = 'mult_borlette';
  static const String multiplicateurMarriage  = 'mult_mariage';
  static const String multiplicateurLotto3    = 'mult_lotto3';
  static const String multiplicateurSel       = 'mult_sel';

  // Limites par défaut
  static const String limitJournaliereDefaut = 'limite_journaliere_defaut';
  static const String limitParBouleDefaut    = 'limite_boule_defaut';

  // Informations app
  static const String nomLotterie   = 'nom_lotterie';
  static const String telephone     = 'telephone_contact';
  static const String adresse       = 'adresse_siege';
  static const String devise        = 'devise';

  // Fonctionnalités
  static const String ventesActives  = 'ventes_actives';
  static const String maintenanceMode = 'maintenance_mode';
}

// ── Notifier ──────────────────────────────────────────────────
class SettingsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> updateSetting({
    required String  key,
    required dynamic valeur,
    required String  description,
  }) async {
    state = const AsyncLoading();
    final session = ref.read(authSessionProvider).valueOrNull;
    final result = await ref
        .read(settingsRepositoryProvider)
        .upsertSetting(
          key:         key,
          valeur:      valeur,
          description: description,
          updatedBy:   session?.uid ?? '',
        );
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> deleteSetting(String key) async {
    state = const AsyncLoading();
    final result = await ref
        .read(settingsRepositoryProvider)
        .deleteSetting(key);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, void>(
  SettingsNotifier.new,
);