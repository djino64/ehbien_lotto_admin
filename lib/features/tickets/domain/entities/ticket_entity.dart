// lib/features/tickets/domain/entities/ticket_entity.dart

import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_item_entity.dart';
import 'package:equatable/equatable.dart';

enum TicketStatus {
  brouillon,
  valide,
  gagnant,
  perdant,
  paye,
  annule,
}

class TicketEntity extends Equatable {
  final String        id;
  final String        codeUnique;
  final String        agentId;
  final String        succursaleId;
  final String        tirageId;
  final TicketStatus  status;
  final double        montantTotal;
  final double?       gainTotal;
  final bool          gagnant;
  final bool          paye;
  final DateTime      createdAt;
  final DateTime?     validatedAt;
  final List<TicketItemEntity> items;
  final String?       agentNom;
  final String?       succursaleNom;
  final String?       tirageNom;

  const TicketEntity({
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
    this.items = const [],
    this.agentNom,
    this.succursaleNom,
    this.tirageNom,
  });

  bool get isGagnant => status == TicketStatus.gagnant;
  bool get isPaye    => status == TicketStatus.paye;
  bool get isAnnule  => status == TicketStatus.annule;
  bool get isValide  => status == TicketStatus.valide;

  TicketEntity copyWith({
    TicketStatus?           status,
    double?                 gainTotal,
    bool?                   gagnant,
    bool?                   paye,
    DateTime?               validatedAt,
    List<TicketItemEntity>? items,
  }) {
    return TicketEntity(
      id:           id,
      codeUnique:   codeUnique,
      agentId:      agentId,
      succursaleId: succursaleId,
      tirageId:     tirageId,
      status:       status      ?? this.status,
      montantTotal: montantTotal,
      gainTotal:    gainTotal   ?? this.gainTotal,
      gagnant:      gagnant     ?? this.gagnant,
      paye:         paye        ?? this.paye,
      createdAt:    createdAt,
      validatedAt:  validatedAt ?? this.validatedAt,
      items:        items       ?? this.items,
      agentNom:     agentNom,
      succursaleNom: succursaleNom,
      tirageNom:    tirageNom,
    );
  }

  @override
  List<Object?> get props => [
    id, codeUnique, agentId, succursaleId,
    tirageId, status, montantTotal, createdAt,
  ];
}