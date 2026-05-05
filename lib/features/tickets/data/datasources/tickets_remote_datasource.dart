// lib/features/tickets/data/datasources/tickets_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/features/tickets/data/models/ticket_item_model.dart';
import 'package:ehbien_lotto_admin/features/tickets/data/models/ticket_model.dart';

abstract class TicketsRemoteDatasource {
  Stream<List<TicketModel>> watchAllTickets({int limit = 50});
  Stream<List<TicketModel>> watchTicketsByAgent(
      String agentId, {int limit = 50});
  Stream<List<TicketModel>> watchTicketsByTirage(String tirageId);
  Future<TicketModel> getTicketById(String id);
  Future<TicketModel?> getTicketByCode(String codeUnique);
  Future<List<TicketItemModel>> getTicketItems(String ticketId);
  Future<void> updateTicketStatus(String id, String status);
  Future<void> markTicketAsWinner(String id, double gainTotal);
  Future<void> markTicketAsPaid(String id);
  Future<List<TicketModel>> getTicketsByDateRange({
    required DateTime from,
    required DateTime to,
    String? agentId,
    String? succursaleId,
    String? tirageId,
  });
}

class TicketsRemoteDatasourceImpl implements TicketsRemoteDatasource {
  final FirebaseFirestore _firestore;

  TicketsRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.tickets);

  @override
  Stream<List<TicketModel>> watchAllTickets({int limit = 50}) {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map(TicketModel.fromFirestore).toList());
  }

  @override
  Stream<List<TicketModel>> watchTicketsByAgent(
      String agentId, {int limit = 50}) {
    return _col
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map(TicketModel.fromFirestore).toList());
  }

  @override
  Stream<List<TicketModel>> watchTicketsByTirage(String tirageId) {
    return _col
        .where('tirageId', isEqualTo: tirageId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(TicketModel.fromFirestore).toList());
  }

  @override
  Future<TicketModel> getTicketById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) {
        throw const FirestoreException(
            'Ticket introuvable.', code: 'not-found');
      }
      return TicketModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<TicketModel?> getTicketByCode(String codeUnique) async {
    try {
      final snap = await _col
          .where('codeUnique', isEqualTo: codeUnique)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return TicketModel.fromFirestore(snap.docs.first);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<List<TicketItemModel>> getTicketItems(String ticketId) async {
    try {
      final snap = await _col
          .doc(ticketId)
          .collection('items')
          .get();
      return snap.docs
          .map(TicketItemModel.fromFirestore)
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> updateTicketStatus(String id, String status) async {
    try {
      await _col.doc(id).update({
        'statut':    status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> markTicketAsWinner(String id, double gainTotal) async {
    try {
      await _col.doc(id).update({
        'statut':    'gagnant',
        'gagnant':   true,
        'gainTotal': gainTotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> markTicketAsPaid(String id) async {
    try {
      await _col.doc(id).update({
        'statut':    'paye',
        'paye':      true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<List<TicketModel>> getTicketsByDateRange({
    required DateTime from,
    required DateTime to,
    String? agentId,
    String? succursaleId,
    String? tirageId,
  }) async {
    try {
      Query query = _col
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(to))
          .orderBy('createdAt', descending: true);

      if (agentId != null) {
        query = query.where('agentId', isEqualTo: agentId);
      }
      if (succursaleId != null) {
        query = query.where('succursaleId', isEqualTo: succursaleId);
      }
      if (tirageId != null) {
        query = query.where('tirageId', isEqualTo: tirageId);
      }

      final snap = await query.get();
      return snap.docs
          .map(TicketModel.fromFirestore)
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}