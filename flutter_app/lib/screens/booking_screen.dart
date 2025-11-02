import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atharna/services/language_service.dart';
import 'package:atharna/services/auth_service.dart';
import 'package:atharna/services/booking_service.dart';
import 'package:atharna/utils/translations.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _bookingService = BookingService();
  
  String? _selectedMuseum;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _visitors = 1;
  bool _isLoading = false;

  List<String> _getMuseumOptions(String lang) => [
    AppTranslations.get('egyptian_museum', lang),
    AppTranslations.get('civilization_museum', lang),
    AppTranslations.get('luxor_museum', lang),
  ];

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _confirmBooking(LanguageService langService) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuseum == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.get('please_fill_all_fields', langService.currentLanguage))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = await _authService.getCurrentUserData();
      if (userData == null) throw Exception('User not found');

      await _bookingService.createBooking(
        userId: userData.uid,
        userName: userData.name,
        userEmail: userData.email,
        museum: _selectedMuseum!,
        date: _selectedDate!,
        time: _selectedTime!.format(context),
        visitors: _visitors,
      );

      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: langService.textDirection,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(AppTranslations.get('booking_confirmed', langService.currentLanguage))),
              ],
            ),
            content: Text(AppTranslations.get('booking_confirmation_message', langService.currentLanguage)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedMuseum = null;
                    _selectedDate = null;
                    _selectedTime = null;
                    _visitors = 1;
                  });
                },
                child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final museums = _getMuseumOptions(langService.currentLanguage);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get('book_visit', langService.currentLanguage),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDropdown(
                  label: AppTranslations.get('select_museum', langService.currentLanguage),
                  value: _selectedMuseum,
                  items: museums,
                  onChanged: (value) => setState(() => _selectedMuseum = value),
                ),
                const SizedBox(height: 16),
                _buildDateSelector(langService),
                const SizedBox(height: 16),
                _buildTimeSelector(langService),
                const SizedBox(height: 16),
                _buildVisitorCounter(langService),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _confirmBooking(langService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                        : Text(
                            AppTranslations.get('confirm_booking', langService.currentLanguage),
                            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.museum, color: Theme.of(context).colorScheme.primary),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  Widget _buildDateSelector(LanguageService langService) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppTranslations.get('select_date', langService.currentLanguage),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
        ),
        child: Text(
          _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : AppTranslations.get('select_date', langService.currentLanguage),
          style: TextStyle(color: _selectedDate != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(LanguageService langService) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppTranslations.get('select_time', langService.currentLanguage),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
        ),
        child: Text(
          _selectedTime != null ? _selectedTime!.format(context) : AppTranslations.get('select_time', langService.currentLanguage),
          style: TextStyle(color: _selectedTime != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildVisitorCounter(LanguageService langService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(AppTranslations.get('number_of_visitors', langService.currentLanguage), style: const TextStyle(fontSize: 16))),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _visitors > 1 ? () => setState(() => _visitors--) : null,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text('$_visitors', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _visitors < 10 ? () => setState(() => _visitors++) : null,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
