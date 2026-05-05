// lib/features/succursales/data/models/succursale_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/succursales/domain/entities/succursale_entity.dart';

class SuccursaleModel {
  final String id;
  final String nom;
  final String adresse;
  final String? telephone;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SuccursaleModel({
    required this.id,
    required this.nom,
    required this.adresse,
    this.telephone,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory SuccursaleModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SuccursaleModel(
      id:        doc.id,
      nom:       d['nom']       as String? ?? '',
      adresse:   d['adresse']   as String? ?? '',
      telephone: d['telephone'] as String?,
      status:    d['status']    as String? ?? 'actif',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'nom':       nom,
    'adresse':   adresse,
    'telephone': telephone,
    'status':    status,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  SuccursaleEntity toEntity({int nombreAgents = 0}) => SuccursaleEntity(
    id:           id,
    nom:          nom,
    adresse:      adresse,
    telephone:    telephone,
    status:       status == 'actif'
                    ? SuccursaleStatus.actif
                    : SuccursaleStatus.inactif,
    nombreAgents: nombreAgents,
    createdAt:    createdAt,
    updatedAt:    updatedAt,
  );
}