// lib/features/primes/data/models/prime_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/primes/domain/entities/prime_entity.dart';

class PrimeModel {
  final String id;
  final String? agentId;
  final String? tirageId;
  final String? ticketId;
  final String type;
  final double montant;
  final String regle;
  final DateTime createdAt;

  const PrimeModel({
    required this.id,
    this.agentId,
    this.tirageId,
    this.ticketId,
    required this.type,
    required this.montant,
    required this.regle,
    required this.createdAt,
  });

  factory PrimeModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PrimeModel(
      id:        doc.id,
      agentId:   d['agentId']   as String?,
      tirageId:  d['tirageId']  as String?,
      ticketId:  d['ticketId']  as String?,
      type:      d['type']      as String? ?? 'commission',
      montant:   (d['montant']  as num?)?.toDouble() ?? 0.0,
      regle:     d['regle']     as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'agentId':   agentId,
    'tirageId':  tirageId,
    'ticketId':  ticketId,
    'type':      type,
    'montant':   montant,
    'regle':     regle,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  PrimeEntity toEntity({String? agentNom, String? tirageNom}) => PrimeEntity(
    id:        id,
    agentId:   agentId,
    tirageId:  tirageId,
    ticketId:  ticketId,
    type:      _parseType(type),
    montant:   montant,
    regle:     regle,
    createdAt: createdAt,
    agentNom:  agentNom,
    tirageNom: tirageNom,
  );

  static PrimeType _parseType(String t) => switch (t) {
    'prime'  => PrimeType.prime,
    'bonus'  => PrimeType.bonus,
    _        => PrimeType.commission,
  };
}