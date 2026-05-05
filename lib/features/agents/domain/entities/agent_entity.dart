// lib/features/agents/domain/entities/agent_entity.dart

import 'package:equatable/equatable.dart';

enum AgentStatus { actif, inactif, bloque }

class AgentEntity extends Equatable {
  final String id;
  final String userId;
  final String succursaleId;
  final String nom;
  final String phone;
  final AgentStatus status;
  final double limiteJournaliere;
  final bool motDePasseTemp;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Données jointes (non stockées dans Firestore)
  final String? succursaleNom;

  const AgentEntity({
    required this.id,
    required this.userId,
    required this.succursaleId,
    required this.nom,
    required this.phone,
    required this.status,
    required this.limiteJournaliere,
    required this.motDePasseTemp,
    required this.createdAt,
    this.updatedAt,
    this.succursaleNom,
  });

  bool get isActif  => status == AgentStatus.actif;
  bool get isBloque => status == AgentStatus.bloque;

  AgentEntity copyWith({
    String? succursaleId,
    String? nom,
    String? phone,
    AgentStatus? status,
    double? limiteJournaliere,
    bool? motDePasseTemp,
    DateTime? updatedAt,
    String? succursaleNom,
  }) {
    return AgentEntity(
      id:                id,
      userId:            userId,
      succursaleId:      succursaleId      ?? this.succursaleId,
      nom:               nom               ?? this.nom,
      phone:             phone             ?? this.phone,
      status:            status            ?? this.status,
      limiteJournaliere: limiteJournaliere ?? this.limiteJournaliere,
      motDePasseTemp:    motDePasseTemp    ?? this.motDePasseTemp,
      createdAt:         createdAt,
      updatedAt:         updatedAt         ?? this.updatedAt,
      succursaleNom:     succursaleNom     ?? this.succursaleNom,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, succursaleId, nom, phone,
    status, limiteJournaliere, motDePasseTemp,
    createdAt, updatedAt,
  ];
}