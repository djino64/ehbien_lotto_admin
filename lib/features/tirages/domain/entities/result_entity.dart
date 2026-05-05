// lib/features/tirages/domain/entities/result_entity.dart

import 'package:equatable/equatable.dart';

class ResultEntity extends Equatable {
  final String id;
  final String tirageId;
  final List<String> boules;
  final DateTime publishedAt;
  final String publishedBy;

  const ResultEntity({
    required this.id,
    required this.tirageId,
    required this.boules,
    required this.publishedAt,
    required this.publishedBy,
  });

  @override
  List<Object?> get props =>
      [id, tirageId, boules, publishedAt, publishedBy];
}