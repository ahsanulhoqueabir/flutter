import 'package:flutter/foundation.dart';

@immutable
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    birthDate: DateTime.tryParse(json['birthDate'] as String? ?? ''),
  );

  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? birthDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'birthDate': birthDate?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.birthDate == birthDate;

  @override
  int get hashCode => Object.hash(id, name, email, phone, birthDate);
}

/// Result of a successful sign in or registration.
typedef AuthSession = ({String token, User user});
