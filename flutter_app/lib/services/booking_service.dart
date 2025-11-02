import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atharna/models/booking_model.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // EmailJS credentials
  final String serviceId = 'service_u3cftud';
  final String templateId = 'template_u8bese8';
  final String publicKey = 'Lib9WX3wUt9VwSQzT';

  Future<BookingModel> createBooking({
    required String userId,
    required String userName,
    required String userEmail,
    required String museum,
    required DateTime date,
    required String time,
    required int visitors,
  }) async {
    final now = DateTime.now();
    final bookingCode = _uuid.v4().substring(0, 8).toUpperCase();

    final booking = BookingModel(
      id: '',
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      museum: museum,
      date: date,
      time: time,
      visitors: visitors,
      bookingCode: bookingCode,
      createdAt: now,
      updatedAt: now,
    );

    // Save booking to Firestore
    final docRef = await _firestore.collection('bookings').add(booking.toJson());

    // Send email confirmation
    await sendBookingEmail(
      userName: userName,
      userEmail: userEmail,
      museum: museum,
      date: date,
      time: time,
      visitors: visitors,
      bookingCode: bookingCode,
    );

    // Log email sent status
    await _firestore.collection('emailLogs').add({
      'user_email': userEmail,
      'user_name': userName,
      'museum': museum,
      'date': Timestamp.fromDate(date),
      'time': time,
      'visitors': visitors,
      'booking_code': bookingCode,
      'sent_at': Timestamp.fromDate(now),
      'status': 'sent',
    });

    return booking.copyWith(id: docRef.id);
  }

  /// 📧 Send email using EmailJS API
  Future<void> sendBookingEmail({
    required String userName,
    required String userEmail,
    required String museum,
    required DateTime date,
    required String time,
    required int visitors,
    required String bookingCode,
  }) async {
    const String emailJsUrl = 'https://api.emailjs.com/api/v1.0/email/send';

    final body = {
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': publicKey,
      'template_params': {
        'user_name': userName,
        'email': userEmail,
        'museum': museum,
        'date': date.toString().split(' ')[0],
        'time': time,
        'visitors': visitors.toString(),
        'booking_code': bookingCode,
      },
    };

    final response = await http.post(
      Uri.parse(emailJsUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }

  /// Get user bookings
  Stream<List<BookingModel>> getUserBookings(String userId) => _firestore
      .collection('bookings')
      .where('user_id', isEqualTo: userId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => BookingModel.fromJson(doc.data(), doc.id)).toList());

  /// Cancel booking
  Future<void> cancelBooking(String bookingId) async =>
      await _firestore.collection('bookings').doc(bookingId).delete();
}
