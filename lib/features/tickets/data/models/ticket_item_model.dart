// lib/features/tickets/data/models/ticket_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_item_entity.dart';

class TicketItemModel {
  final String id;
  final String ticketId;
  final String typeJeu;
  final List<String> boules;
  final double montant;
  final double gainPotentiel;

  const TicketItemModel({
    required this.id,
    required this.ticketId,
    required this.typeJeu,
    required this.boules,
    required this.montant,
    required this.gainPotentiel,
  });

  factory TicketItemModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TicketItemModel(
      id:             doc.id,
      ticketId:       d['ticketId']      as String? ?? '',
      typeJeu:        d['typeJeu']       as String? ?? 'borlette',
      boules:         List<String>.from(d['boules'] as List? ?? []),
      montant:        (d['montant']       as num?)?.toDouble() ?? 0.0,
      gainPotentiel:  (d['gainPotentiel'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'ticketId':      ticketId,
    'typeJeu':       typeJeu,
    'boules':        boules,
    'montant':       montant,
    'gainPotentiel': gainPotentiel,
  };

  TicketItemEntity toEntity() => TicketItemEntity(
    id:            id,
    ticketId:      ticketId,
    typeJeu:       _parseType(typeJeu),
    boules:        boules,
    montant:       montant,
    gainPotentiel: gainPotentiel,
  );

  static TypeJeu _parseType(String t) => switch (t) {
    'mariage' => TypeJeu.mariage,
    'lotto3'  => TypeJeu.lotto3,
    'sel'     => TypeJeu.sel,
    _         => TypeJeu.borlette,
  };
}