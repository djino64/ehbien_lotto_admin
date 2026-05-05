// lib/features/tirages/domain/entities/tirage_entity.dart

import 'package:equatable/equatable.dart';

enum TirageType   { borlette, mariage, lotto3, sel }
enum TirageStatus { ouvert, ferme, publie, annule }

class TirageEntity extends Equatable {
  final String id;
  final String nom;
  final TirageType type;
  final DateTime heurePrevu;
  final TirageStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TirageEntity({
    required this.id,
    required this.nom,
    required this.type,
    required this.heurePrevu,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isOuvert => status == TirageStatus.ouvert;
  bool get isPublie => status == TirageStatus.publie;

  TirageEntity copyWith({
    String? nom,
    TirageType? type,
    DateTime? heurePrevu,
    TirageStatus? status,
    DateTime? updatedAt,
  }) {
    return TirageEntity(
      id:         id,
      nom:        nom        ?? this.nom,
      type:       type       ?? this.type,
      heurePrevu: heurePrevu ?? this.heurePrevu,
      status:     status     ?? this.status,
      createdAt:  createdAt,
      updatedAt:  updatedAt  ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, nom, type, heurePrevu, status, createdAt];
}