// lib/features/blocages/domain/entities/blocage_entity.dart

import 'package:equatable/equatable.dart';

class BlocageEntity extends Equatable {
  final String id;
  final String boule;
  final String? typeJeu;
  final String? agentId;
  final String? succursaleId;
  final String? tirageId;
  final bool global;
  final bool permanent;
  final DateTime? expiresAt;
  final String createdBy;
  final DateTime createdAt;

  // Données jointes
  final String? agentNom;

  const BlocageEntity({
    required this.id,
    required this.boule,
    this.typeJeu,
    this.agentId,
    this.succursaleId,
    this.tirageId,
    required this.global,
    required this.permanent,
    this.expiresAt,
    required this.createdBy,
    required this.createdAt,
    this.agentNom,
  });

  bool get isExpired =>
      !permanent && expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isActive => !isExpired;

  @override
  List<Object?> get props =>
      [id, boule, typeJeu, agentId, global, permanent, expiresAt];
}