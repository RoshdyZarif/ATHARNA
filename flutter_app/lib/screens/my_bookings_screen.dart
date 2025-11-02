import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atharna/services/language_service.dart';
import 'package:atharna/services/auth_service.dart';
import 'package:atharna/services/booking_service.dart';
import 'package:atharna/models/booking_model.dart';
import 'package:atharna/utils/translations.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final authService = AuthService();
    final bookingService = BookingService();

    return Directionality(
      textDirection: langService.textDirection,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppTranslations.get('my_bookings', langService.currentLanguage),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<BookingModel>>(
                stream: bookingService.getUserBookings(authService.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            AppTranslations.get('no_bookings', langService.currentLanguage),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final booking = snapshot.data![index];
                      return _BookingCard(booking: booking, langService: langService, bookingService: bookingService);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final LanguageService langService;
  final BookingService bookingService;

  const _BookingCard({
    required this.booking,
    required this.langService,
    required this.bookingService,
  });

  Future<void> _cancelBooking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: langService.textDirection,
        child: AlertDialog(
          title: Text(AppTranslations.get('cancel', langService.currentLanguage)),
          content: Text(langService.isArabic ? 'هل تريد إلغاء هذا الحجز؟' : 'Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(langService.isArabic ? 'لا' : 'No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(langService.isArabic ? 'نعم' : 'Yes', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await bookingService.cancelBooking(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('booking_cancelled', langService.currentLanguage)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.museum, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking.museum,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: AppTranslations.get('date', langService.currentLanguage),
                  value: DateFormat('yyyy-MM-dd').format(booking.date),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.access_time,
                  label: AppTranslations.get('time', langService.currentLanguage),
                  value: booking.time,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.people,
                  label: AppTranslations.get('visitors', langService.currentLanguage),
                  value: '${booking.visitors}',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.confirmation_number,
                  label: AppTranslations.get('booking_code', langService.currentLanguage),
                  value: booking.bookingCode,
                  isHighlighted: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelBooking(context),
                    icon: Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
                    label: Text(
                      AppTranslations.get('cancel', langService.currentLanguage),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
