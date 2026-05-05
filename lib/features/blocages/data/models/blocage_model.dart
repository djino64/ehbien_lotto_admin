// lib/features/blocages/data/models/blocage_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/blocages/domain/entities/blocage_entity.dart';

class BlocageModel {
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

  const BlocageModel({
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
  });

  factory BlocageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BlocageModel(
      id:            doc.id,
      boule:         d['boule']         as String? ?? '',
      typeJeu:       d['typeJeu']       as String?,
      agentId:       d['agentId']       as String?,
      succursaleId:  d['succursaleId']  as String?,
      tirageId:      d['tirageId']      as String?,
      global:        d['global']        as bool?   ?? false,
      permanent:     d['permanent']     as bool?   ?? false,
      expiresAt:     (d['expiresAt']    as Timestamp?)?.toDate(),
      createdBy:     d['createdBy']     as String? ?? '',
      createdAt:     (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'boule':        boule,
    'typeJeu':      typeJeu,
    'agentId':      agentId,
    'succursaleId': succursaleId,
    'tirageId':     tirageId,
    'global':       global,
    'permanent':    permanent,
    'expiresAt':    expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    'createdBy':    createdBy,
    'createdAt':    Timestamp.fromDate(createdAt),
  };

  BlocageEntity toEntity({String? agentNom}) => BlocageEntity(
    id:            id,
    boule:         boule,
    typeJeu:       typeJeu,
    agentId:       agentId,
    succursaleId:  succursaleId,
    tirageId:      tirageId,
    global:        global,
    permanent:     permanent,
    expiresAt:     expiresAt,
    createdBy:     createdBy,
    createdAt:     createdAt,
    agentNom:      agentNom,
  );
}