// lib/features/agents/data/models/agent_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';

class AgentModel {
  final String id;
  final String userId;
  final String succursaleId;
  final String nom;
  final String phone;
  final String status;
  final double limiteJournaliere;
  final bool motDePasseTemp;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AgentModel({
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
  });

  factory AgentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AgentModel(
      id:                doc.id,
      userId:            d['userId']            as String? ?? '',
      succursaleId:      d['succursaleId']      as String? ?? '',
      nom:               d['nom']               as String? ?? '',
      phone:             d['phone']             as String? ?? '',
      status:            d['status']            as String? ?? 'actif',
      limiteJournaliere: (d['limiteJournaliere'] as num?)?.toDouble() ?? 0.0,
      motDePasseTemp:    d['motDePasseTemp']    as bool?   ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId':            userId,
    'succursaleId':      succursaleId,
    'nom':               nom,
    'phone':             phone,
    'status':            status,
    'limiteJournaliere': limiteJournaliere,
    'motDePasseTemp':    motDePasseTemp,
    'createdAt':         Timestamp.fromDate(createdAt),
    'updatedAt':         FieldValue.serverTimestamp(),
  };

  AgentEntity toEntity({String? succursaleNom}) => AgentEntity(
    id:                id,
    userId:            userId,
    succursaleId:      succursaleId,
    nom:               nom,
    phone:             phone,
    status:            _parseStatus(status),
    limiteJournaliere: limiteJournaliere,
    motDePasseTemp:    motDePasseTemp,
    createdAt:         createdAt,
    updatedAt:         updatedAt,
    succursaleNom:     succursaleNom,
  );

  static AgentStatus _parseStatus(String s) => switch (s) {
    'inactif' => AgentStatus.inactif,
    'bloque'  => AgentStatus.bloque,
    _         => AgentStatus.actif,
  };
}