// lib/features/succursales/domain/entities/succursale_entity.dart

import 'package:equatable/equatable.dart';

enum SuccursaleStatus { actif, inactif }

class SuccursaleEntity extends Equatable {
  final String id;
  final String nom;
  final String adresse;
  final String? telephone;
  final SuccursaleStatus status;
  final int nombreAgents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SuccursaleEntity({
    required this.id,
    required this.nom,
    required this.adresse,
    this.telephone,
    required this.status,
    this.nombreAgents = 0,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActif => status == SuccursaleStatus.actif;

  SuccursaleEntity copyWith({
    String? nom,
    String? adresse,
    String? telephone,
    SuccursaleStatus? status,
    int? nombreAgents,
    DateTime? updatedAt,
  }) {
    return SuccursaleEntity(
      id:           id,
      nom:          nom          ?? this.nom,
      adresse:      adresse      ?? this.adresse,
      telephone:    telephone    ?? this.telephone,
      status:       status       ?? this.status,
      nombreAgents: nombreAgents ?? this.nombreAgents,
      createdAt:    createdAt,
      updatedAt:    updatedAt    ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, nom, adresse, telephone, status, nombreAgents, createdAt];
}