// lib/features/rapports/domain/entities/rapport_entity.dart

import 'package:equatable/equatable.dart';

class RapportEntity extends Equatable {
  final String id;
  final String type;
  final String periode;
  final String? agentId;
  final String? succursaleId;
  final Map<String, dynamic> donnees;
  final DateTime genereAt;

  const RapportEntity({
    required this.id,
    required this.type,
    required this.periode,
    this.agentId,
    this.succursaleId,
    required this.donnees,
    required this.genereAt,
  });

  double get totalVentes   =>
      (donnees['totalVentes']   as num?)?.toDouble() ?? 0.0;
  double get totalGains    =>
      (donnees['totalGains']    as num?)?.toDouble() ?? 0.0;
  double get totalRecettes =>
      (donnees['totalRecettes'] as num?)?.toDouble() ?? 0.0;
  int    get nombreTickets =>
      (donnees['nombreTickets'] as num?)?.toInt()    ?? 0;

  @override
  List<Object?> get props => [id, type, periode, genereAt];
}