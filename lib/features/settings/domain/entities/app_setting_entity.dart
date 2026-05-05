// lib/features/settings/domain/entities/app_setting_entity.dart

import 'package:equatable/equatable.dart';

class AppSettingEntity extends Equatable {
  final String id;
  final dynamic valeur;
  final String description;
  final DateTime updatedAt;
  final String updatedBy;

  const AppSettingEntity({
    required this.id,
    required this.valeur,
    required this.description,
    required this.updatedAt,
    required this.updatedBy,
  });

  String get valeurString => valeur?.toString() ?? '';
  double? get valeurDouble => double.tryParse(valeurString);
  int?    get valeurInt    => int.tryParse(valeurString);
  bool    get valeurBool   => valeur == true || valeur == 'true';

  @override
  List<Object?> get props => [id, valeur, updatedAt];
}