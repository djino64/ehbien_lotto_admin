// lib/features/tickets/data/models/ticket_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';

class TicketModel {
  final String id;
  final String codeUnique;
  final String agentId;
  final String succursaleId;
  final String tirageId;
  final String status;
  final double montantTotal;
  final double? gainTotal;
  final bool gagnant;
  final bool paye;
  final DateTime createdAt;
  final DateTime? validatedAt;

  const TicketModel({
    required this.id,
    required this.codeUnique,
    required this.agentId,
    required this.succursaleId,
    required this.tirageId,
    required this.status,
    required this.montantTotal,
    this.gainTotal,
    required this.gagnant,
    required this.paye,
    required this.createdAt,
    this.validatedAt,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id:            doc.id,
      codeUnique:    d['codeUnique']   as String? ?? '',
      agentId:       d['agentId']      as String? ?? '',
      succursaleId:  d['succursaleId'] as String? ?? '',
      tirageId:      d['tirageId']     as String? ?? '',
      status:        d['statut']       as String? ?? 'brouillon',
      montantTotal:  (d['montantTotal'] as num?)?.toDouble() ?? 0.0,
      gainTotal:     (d['gainTotal']    as num?)?.toDouble(),
      gagnant:       d['gagnant']      as bool?   ?? false,
      paye:          d['paye']         as bool?   ?? false,
      createdAt:     (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      validatedAt:   (d['validatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'codeUnique':   codeUnique,
    'agentId':      agentId,
    'succursaleId': succursaleId,
    'tirageId':     tirageId,
    'statut':       status,
    'montantTotal': montantTotal,
    'gainTotal':    gainTotal,
    'gagnant':      gagnant,
    'paye':         paye,
    'createdAt':    Timestamp.fromDate(createdAt),
    'validatedAt':  validatedAt != null
                      ? Timestamp.fromDate(validatedAt!)
                      : null,
  };

  TicketEntity toEntity() => TicketEntity(
    id:            id,
    codeUnique:    codeUnique,
    agentId:       agentId,
    succursaleId:  succursaleId,
    tirageId:      tirageId,
    status:        _parseStatus(status),
    montantTotal:  montantTotal,
    gainTotal:     gainTotal,
    gagnant:       gagnant,
    paye:          paye,
    createdAt:     createdAt,
    validatedAt:   validatedAt,
  );

  static TicketStatus _parseStatus(String s) => switch (s) {
    'valide'    => TicketStatus.valide,
    'gagnant'   => TicketStatus.gagnant,
    'perdant'   => TicketStatus.perdant,
    'paye'      => TicketStatus.paye,
    'annule'    => TicketStatus.annule,
    _           => TicketStatus.brouillon,
  };
}