import 'package:flutter/foundation.dart';

/// Immutable model. Keep models plain: fields, `fromJson`, `toJson`, equality.
@immutable
class Post {
  const Post({required this.id, required this.userId, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as int,
    userId: json['userId'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
  );

  final int id;
  final int userId;
  final String title;
  final String body;

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'title': title, 'body': body};

  @override
  bool operator ==(Object other) =>
      other is Post &&
      other.id == id &&
      other.userId == userId &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, userId, title, body);
}
