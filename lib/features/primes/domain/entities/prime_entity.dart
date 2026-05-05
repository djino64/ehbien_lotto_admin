// lib/features/primes/domain/entities/prime_entity.dart

import 'package:equatable/equatable.dart';

enum PrimeType { commission, prime, bonus }

class PrimeEntity extends Equatable {
  final String id;
  final String? agentId;
  final String? tirageId;
  final String? ticketId;
  final PrimeType type;
  final double montant;
  final String regle;
  final DateTime createdAt;

  // Données jointes
  final String? agentNom;
  final String? tirageNom;

  const PrimeEntity({
    required this.id,
    this.agentId,
    this.tirageId,
    this.ticketId,
    required this.type,
    required this.montant,
    required this.regle,
    required this.createdAt,
    this.agentNom,
    this.tirageNom,
  });

  @override
  List<Object?> get props =>
      [id, agentId, tirageId, type, montant, createdAt];
}