// lib/features/settings/data/models/app_setting_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/entities/app_setting_entity.dart';

class AppSettingModel {
  final String   id;
  final dynamic  valeur;
  final String   description;
  final DateTime updatedAt;
  final String   updatedBy;

  const AppSettingModel({
    required this.id,
    required this.valeur,
    required this.description,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory AppSettingModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppSettingModel(
      id:          doc.id,
      valeur:      d['valeur'],
      description: d['description'] as String? ?? '',
      updatedAt:   (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy:   d['updatedBy']  as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'valeur':      valeur,
    'description': description,
    'updatedAt':   FieldValue.serverTimestamp(),
    'updatedBy':   updatedBy,
  };

  AppSettingEntity toEntity() => AppSettingEntity(
    id:          id,
    valeur:      valeur,
    description: description,
    updatedAt:   updatedAt,
    updatedBy:   updatedBy,
  );
}