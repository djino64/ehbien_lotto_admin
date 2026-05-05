// lib/features/tickets/domain/entities/ticket_item_entity.dart

import 'package:equatable/equatable.dart';

enum TypeJeu { borlette, mariage, lotto3, sel }

class TicketItemEntity extends Equatable {
  final String id;
  final String ticketId;
  final TypeJeu typeJeu;
  final List<String> boules;
  final double montant;
  final double gainPotentiel;

  const TicketItemEntity({
    required this.id,
    required this.ticketId,
    required this.typeJeu,
    required this.boules,
    required this.montant,
    required this.gainPotentiel,
  });

  @override
  List<Object?> get props =>
      [id, ticketId, typeJeu, boules, montant, gainPotentiel];
}