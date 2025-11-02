import 'package:cloud_firestore/cloud_firestore.dart';

class ArtifactModel {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final Map<String, String> dynasty;
  final String qrCode;
  final DateTime createdAt;

  ArtifactModel({
    required this.id,
    required this.name,
    required this.description,
    required this.dynasty,
    required this.qrCode,
    required this.createdAt,
  });

  factory ArtifactModel.fromJson(Map<String, dynamic> json, String id) => ArtifactModel(
    id: id,
    name: Map<String, String>.from(json['name'] as Map),
    description: Map<String, String>.from(json['description'] as Map),
    dynasty: Map<String, String>.from(json['dynasty'] as Map),
    qrCode: json['qr_code'] as String,
    createdAt: (json['created_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'dynasty': dynasty,
    'qr_code': qrCode,
    'created_at': Timestamp.fromDate(createdAt),
  };

  ArtifactModel copyWith({
    String? id,
    Map<String, String>? name,
    Map<String, String>? description,
    Map<String, String>? dynasty,
    String? qrCode,
    DateTime? createdAt,
  }) => ArtifactModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    dynasty: dynasty ?? this.dynasty,
    qrCode: qrCode ?? this.qrCode,
    createdAt: createdAt ?? this.createdAt,
  );
}
