// lib/features/tirages/data/models/tirage_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';

class TirageModel {
  final String id;
  final String nom;
  final String type;
  final DateTime heurePrevu;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TirageModel({
    required this.id,
    required this.nom,
    required this.type,
    required this.heurePrevu,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory TirageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TirageModel(
      id:         doc.id,
      nom:        d['nom']    as String? ?? '',
      type:       d['type']   as String? ?? 'borlette',
      heurePrevu: (d['heurePrevu'] as Timestamp).toDate(),
      status:     d['status'] as String? ?? 'ouvert',
      createdAt:  (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:  (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'nom':        nom,
    'type':       type,
    'heurePrevu': Timestamp.fromDate(heurePrevu),
    'status':     status,
    'createdAt':  Timestamp.fromDate(createdAt),
    'updatedAt':  FieldValue.serverTimestamp(),
  };

  TirageEntity toEntity() => TirageEntity(
    id:         id,
    nom:        nom,
    type:       _parseType(type),
    heurePrevu: heurePrevu,
    status:     _parseStatus(status),
    createdAt:  createdAt,
    updatedAt:  updatedAt,
  );

  static TirageType _parseType(String t) => switch (t) {
    'mariage'  => TirageType.mariage,
    'lotto3'   => TirageType.lotto3,
    'sel'      => TirageType.sel,
    _          => TirageType.borlette,
  };

  static TirageStatus _parseStatus(String s) => switch (s) {
    'ferme'   => TirageStatus.ferme,
    'publie'  => TirageStatus.publie,
    'annule'  => TirageStatus.annule,
    _         => TirageStatus.ouvert,
  };
}