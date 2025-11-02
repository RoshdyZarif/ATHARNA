import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String museum;
  final DateTime date;
  final String time;
  final int visitors;
  final String bookingCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.museum,
    required this.date,
    required this.time,
    required this.visitors,
    required this.bookingCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String id) => BookingModel(
    id: id,
    userId: json['user_id'] as String,
    userName: json['user_name'] as String,
    userEmail: json['user_email'] as String,
    museum: json['museum'] as String,
    date: (json['date'] as Timestamp).toDate(),
    time: json['time'] as String,
    visitors: json['visitors'] as int,
    bookingCode: json['booking_code'] as String,
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_name': userName,
    'user_email': userEmail,
    'museum': museum,
    'date': Timestamp.fromDate(date),
    'time': time,
    'visitors': visitors,
    'booking_code': bookingCode,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? museum,
    DateTime? date,
    String? time,
    int? visitors,
    String? bookingCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BookingModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    userEmail: userEmail ?? this.userEmail,
    museum: museum ?? this.museum,
    date: date ?? this.date,
    time: time ?? this.time,
    visitors: visitors ?? this.visitors,
    bookingCode: bookingCode ?? this.bookingCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
