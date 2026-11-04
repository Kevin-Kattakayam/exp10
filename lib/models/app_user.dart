import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Data model representing a User document stored in the Firestore 'users' collection.
class AppUser {
  final String? id; // Firestore document ID
  final String email;
  final String passwordHash;
  final String fullName;
  final String role; // 'Administrator', 'Developer', 'Student', 'Staff'
  final String createdAt;
  final String lastLoginAt;

  const AppUser({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.fullName,
    required this.role,
    required this.createdAt,
    required this.lastLoginAt,
  });

  /// Hash password using SHA-256 for secure Firestore storage.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify candidate password against stored SHA-256 hash.
  bool verifyPassword(String candidatePassword) {
    return passwordHash == hashPassword(candidatePassword);
  }

  /// Convert to Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email.toLowerCase().trim(),
      'passwordHash': passwordHash,
      'fullName': fullName.trim(),
      'role': role,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  /// Factory constructor to parse document data and document ID from Firestore.
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] as String? ?? '',
      passwordHash: map['passwordHash'] as String? ?? '',
      fullName: map['fullName'] as String? ?? 'User',
      role: map['role'] as String? ?? 'Member',
      createdAt: map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      lastLoginAt: map['lastLoginAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? passwordHash,
    String? fullName,
    String? role,
    String? createdAt,
    String? lastLoginAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

