// lib/features/limits/domain/entities/limit_entity.dart

import 'package:equatable/equatable.dart';

class LimitEntity extends Equatable {
  final String id;
  final String? agentId;
  final String? tirageId;
  final String? typeJeu;
  final String? boule;
  final double maxParBoule;
  final double maxGlobal;
  final double currentAmount;
  final DateTime updatedAt;

  // Données jointes
  final String? agentNom;

  const LimitEntity({
    required this.id,
    this.agentId,
    this.tirageId,
    this.typeJeu,
    this.boule,
    required this.maxParBoule,
    required this.maxGlobal,
    required this.currentAmount,
    required this.updatedAt,
    this.agentNom,
  });

  bool get isGlobal => agentId == null;

  double get percentUsed =>
      maxGlobal > 0 ? (currentAmount / maxGlobal).clamp(0.0, 1.0) : 0.0;

  bool get isAtLimit => currentAmount >= maxGlobal;

  @override
  List<Object?> get props =>
      [id, agentId, tirageId, typeJeu, boule, maxParBoule, maxGlobal];
}