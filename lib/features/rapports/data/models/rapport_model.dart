// lib/features/rapports/data/models/rapport_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/rapports/domain/entities/rapport_entity.dart';

class RapportModel {
  final String id;
  final String type;
  final String periode;
  final String? agentId;
  final String? succursaleId;
  final Map<String, dynamic> donnees;
  final DateTime genereAt;

  const RapportModel({
    required this.id,
    required this.type,
    required this.periode,
    this.agentId,
    this.succursaleId,
    required this.donnees,
    required this.genereAt,
  });

  factory RapportModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RapportModel(
      id:            doc.id,
      type:          d['type']          as String? ?? '',
      periode:       d['periode']       as String? ?? '',
      agentId:       d['agentId']       as String?,
      succursaleId:  d['succursaleId']  as String?,
      donnees:       Map<String, dynamic>.from(d['donnees'] as Map? ?? {}),
      genereAt:      (d['genereAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  RapportEntity toEntity() => RapportEntity(
    id:            id,
    type:          type,
    periode:       periode,
    agentId:       agentId,
    succursaleId:  succursaleId,
    donnees:       donnees,
    genereAt:      genereAt,
  );
}