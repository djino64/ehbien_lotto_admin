// lib/features/settings/presentation/providers/settings_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:ehbien_lotto_admin/features/settings/data/models/app_setting_model.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/entities/app_setting_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Stream tous les paramètres ────────────────────────────────
final settingsStreamProvider =
    StreamProvider<List<AppSettingEntity>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.settings)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => AppSettingModel.fromFirestore(d).toEntity())
            .toList(),
      );
});

// ── Paramètre par clé ─────────────────────────────────────────
final settingByKeyProvider =
    Provider.family<AppSettingEntity?, String>((ref, key) {
  final all = ref.watch(settingsStreamProvider).valueOrNull ?? [];
  try {
    return all.firstWhere((s) => s.id == key);
  } catch (_) {
    return null;
  }
});

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
    try {
      final session = ref.read(authSessionProvider).valueOrNull;
      await ref
          .read(firestoreProvider)
          .collection(FirestorePaths.settings)
          .doc(key)
          .set(
        {
          'valeur':      valeur,
          'description': description,
          'updatedAt':   FieldValue.serverTimestamp(),
          'updatedBy':   session?.uid ?? '',
        },
        SetOptions(merge: true),
      );
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, void>(SettingsNotifier.new);