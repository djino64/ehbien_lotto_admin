// lib/features/primes/presentation/providers/primes_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/core/utils/code_generator.dart';
import 'package:ehbien_lotto_admin/features/primes/data/models/prime_model.dart';
import 'package:ehbien_lotto_admin/features/primes/domain/entities/prime_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Stream toutes les primes ──────────────────────────────────
final primesStreamProvider = StreamProvider<List<PrimeEntity>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.commissions)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => PrimeModel.fromFirestore(d).toEntity())
          .toList());
});

// ── Stream primes par agent ───────────────────────────────────
final primesByAgentProvider =
    StreamProvider.family<List<PrimeEntity>, String>((ref, agentId) {
  return ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.commissions)
      .where('agentId', isEqualTo: agentId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => PrimeModel.fromFirestore(d).toEntity())
          .toList());
});

// ── Total primes par agent ────────────────────────────────────
final totalPrimesByAgentProvider =
    Provider.family<double, String>((ref, agentId) {
  final primes =
      ref.watch(primesByAgentProvider(agentId)).valueOrNull ?? [];
  return primes.fold(0.0, (sum, p) => sum + p.montant);
});

// ── Notifier ──────────────────────────────────────────────────
class PrimesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createPrime({
    String? agentId,
    String? tirageId,
    String? ticketId,
    required PrimeType type,
    required double montant,
    required String regle,
  }) async {
    state = const AsyncLoading();
    try {
      final id = CodeGenerator.firestoreId();
      await ref
          .read(firestoreProvider)
          .collection(FirestorePaths.commissions)
          .doc(id)
          .set({
        'agentId':   agentId,
        'tirageId':  tirageId,
        'ticketId':  ticketId,
        'type':      type.name,
        'montant':   montant,
        'regle':     regle,
        'createdAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }

  Future<String?> deletePrime(String id) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(firestoreProvider)
          .collection(FirestorePaths.commissions)
          .doc(id)
          .delete();
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }
}

final primesNotifierProvider =
    AsyncNotifierProvider<PrimesNotifier, void>(PrimesNotifier.new);