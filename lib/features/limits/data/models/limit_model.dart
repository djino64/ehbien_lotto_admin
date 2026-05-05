// lib/features/limits/data/models/limit_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/limits/domain/entities/limit_entity.dart';

class LimitModel {
  final String  id;
  final String? agentId;
  final String? tirageId;
  final String? typeJeu;
  final String? boule;
  final double  maxParBoule;
  final double  maxGlobal;
  final double  currentAmount;
  final DateTime updatedAt;

  const LimitModel({
    required this.id,
    this.agentId,
    this.tirageId,
    this.typeJeu,
    this.boule,
    required this.maxParBoule,
    required this.maxGlobal,
    required this.currentAmount,
    required this.updatedAt,
  });

  factory LimitModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LimitModel(
      id:            doc.id,
      agentId:       d['agentId']       as String?,
      tirageId:      d['tirageId']      as String?,
      typeJeu:       d['typeJeu']       as String?,
      boule:         d['boule']         as String?,
      maxParBoule:   (d['maxParBoule']  as num?)?.toDouble() ?? 0.0,
      maxGlobal:     (d['maxGlobal']    as num?)?.toDouble() ?? 0.0,
      currentAmount: (d['currentAmount'] as num?)?.toDouble() ?? 0.0,
      updatedAt:
          (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'agentId':       agentId,
    'tirageId':      tirageId,
    'typeJeu':       typeJeu,
    'boule':         boule,
    'maxParBoule':   maxParBoule,
    'maxGlobal':     maxGlobal,
    'currentAmount': currentAmount,
    'updatedAt':     FieldValue.serverTimestamp(),
  };

  LimitEntity toEntity({String? agentNom}) => LimitEntity(
    id:            id,
    agentId:       agentId,
    tirageId:      tirageId,
    typeJeu:       typeJeu,
    boule:         boule,
    maxParBoule:   maxParBoule,
    maxGlobal:     maxGlobal,
    currentAmount: currentAmount,
    updatedAt:     updatedAt,
    agentNom:      agentNom,
  );
}