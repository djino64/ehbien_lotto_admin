// lib/features/users/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

enum UserRole { admin, vendeur }

enum UserStatus { actif, inactif, bloque }

class UserEntity extends Equatable {
  final String uid;
  final String phone;
  final String? email;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin   => role == UserRole.admin;
  bool get isVendeur => role == UserRole.vendeur;
  bool get isActif   => status == UserStatus.actif;

  UserEntity copyWith({
    String? phone,
    String? email,
    UserRole? role,
    UserStatus? status,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid:       uid,
      phone:     phone     ?? this.phone,
      email:     email     ?? this.email,
      role:      role      ?? this.role,
      status:    status    ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [uid, phone, email, role, status, createdAt, updatedAt];
}