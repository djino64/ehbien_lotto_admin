// lib/features/notifications/data/models/app_notification_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/entities/app_notification_entity.dart';

class AppNotificationModel {
  final String id;
  final String? agentId;
  final String type;
  final String titre;
  final String message;
  final bool lu;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    this.agentId,
    required this.type,
    required this.titre,
    required this.message,
    required this.lu,
    required this.data,
    required this.createdAt,
  });

  factory AppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppNotificationModel(
      id:        doc.id,
      agentId:   d['agentId'] as String?,
      type:      d['type']    as String? ?? 'message',
      titre:     d['titre']   as String? ?? '',
      message:   d['message'] as String? ?? '',
      lu:        d['lu']      as bool?   ?? false,
      data:      Map<String, dynamic>.from(d['data'] as Map? ?? {}),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'agentId':   agentId,
    'type':      type,
    'titre':     titre,
    'message':   message,
    'lu':        lu,
    'data':      data,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  AppNotificationEntity toEntity() => AppNotificationEntity(
    id:        id,
    agentId:   agentId,
    type:      _parseType(type),
    titre:     titre,
    message:   message,
    lu:        lu,
    data:      data,
    createdAt: createdAt,
  );

  static NotificationType _parseType(String t) => switch (t) {
    'tirage'    => NotificationType.tirage,
    'resultat'  => NotificationType.resultat,
    'gagnant'   => NotificationType.gagnant,
    'blocage'   => NotificationType.blocage,
    _           => NotificationType.message,
  };
}