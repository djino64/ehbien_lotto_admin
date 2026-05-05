// lib/features/users/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/users/domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String phone;
  final String? email;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid:       doc.id,
      phone:     data['phone']  as String? ?? '',
      email:     data['email']  as String?,
      role:      data['role']   as String? ?? 'vendeur',
      status:    data['status'] as String? ?? 'actif',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'phone':     phone,
    'email':     email,
    'role':      role,
    'status':    status,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };

  UserEntity toEntity() => UserEntity(
    uid:       uid,
    phone:     phone,
    email:     email,
    role:      _parseRole(role),
    status:    _parseStatus(status),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static UserRole _parseRole(String r) => switch (r) {
    'admin'   => UserRole.admin,
    _         => UserRole.vendeur,
  };

  static UserStatus _parseStatus(String s) => switch (s) {
    'inactif' => UserStatus.inactif,
    'bloque'  => UserStatus.bloque,
    _         => UserStatus.actif,
  };
}