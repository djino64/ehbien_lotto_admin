// lib/features/notifications/domain/entities/app_notification_entity.dart

import 'package:equatable/equatable.dart';

enum NotificationType { tirage, resultat, gagnant, blocage, message }

class AppNotificationEntity extends Equatable {
  final String id;
  final String? agentId;
  final NotificationType type;
  final String titre;
  final String message;
  final bool lu;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const AppNotificationEntity({
    required this.id,
    this.agentId,
    required this.type,
    required this.titre,
    required this.message,
    required this.lu,
    required this.data,
    required this.createdAt,
  });

  bool get isBroadcast => agentId == null;

  @override
  List<Object?> get props => [id, agentId, type, lu, createdAt];
}