// lib/features/tirages/data/models/result_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/result_entity.dart';

class ResultModel {
  final String id;
  final String tirageId;
  final List<String> boules;
  final DateTime publishedAt;
  final String publishedBy;

  const ResultModel({
    required this.id,
    required this.tirageId,
    required this.boules,
    required this.publishedAt,
    required this.publishedBy,
  });

  factory ResultModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ResultModel(
      id:          doc.id,
      tirageId:    d['tirageId']   as String? ?? '',
      boules:      List<String>.from(d['boules'] as List? ?? []),
      publishedAt: (d['publishedAt'] as Timestamp).toDate(),
      publishedBy: d['publishedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'tirageId':    tirageId,
    'boules':      boules,
    'publishedAt': Timestamp.fromDate(publishedAt),
    'publishedBy': publishedBy,
  };

  ResultEntity toEntity() => ResultEntity(
    id:          id,
    tirageId:    tirageId,
    boules:      boules,
    publishedAt: publishedAt,
    publishedBy: publishedBy,
  );
}