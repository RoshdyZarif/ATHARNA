import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atharna/services/language_service.dart';
import 'package:atharna/services/auth_service.dart';
import 'package:atharna/utils/translations.dart';
import 'package:atharna/screens/booking_screen.dart';
import 'package:atharna/screens/my_bookings_screen.dart';
import 'package:atharna/screens/scanner_screen.dart';
import 'package:atharna/screens/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _authService = AuthService();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getCurrentUserData();
    if (mounted && userData != null) {
      setState(() => _userName = userData.name);
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> _logout(LanguageService langService) async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);

    final screens = [
      _HomeTab(userName: _userName, langService: langService),
      const BookingScreen(),
      const MyBookingsScreen(),
      const ScannerScreen(),
    ];

    return Directionality(
      textDirection: langService.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ATHARNA', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: langService.toggleLanguage,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(langService),
            ),
          ],
        ),
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppTranslations.get('home', langService.currentLanguage),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              label: AppTranslations.get('book_visit', langService.currentLanguage),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark),
              label: AppTranslations.get('my_bookings', langService.currentLanguage),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              label: AppTranslations.get('scan_artifact', langService.currentLanguage),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String userName;
  final LanguageService langService;

  const _HomeTab({required this.userName, required this.langService});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppTranslations.get('welcome', langService.currentLanguage)}, $userName',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTranslations.get('explore_legacy', langService.currentLanguage),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Image.asset('assets/images/logo.png', width: double.infinity, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 32),
            _QuickActionCard(
              icon: Icons.calendar_today,
              title: AppTranslations.get('book_visit', langService.currentLanguage),
              description: langService.isArabic ? 'احجز زيارتك للمتحف الآن' : 'Book your museum visit now',
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _QuickActionCard(
              icon: Icons.bookmark,
              title: AppTranslations.get('my_bookings', langService.currentLanguage),
              description: langService.isArabic ? 'عرض وإدارة حجوزاتك' : 'View and manage your bookings',
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            _QuickActionCard(
              icon: Icons.qr_code_scanner,
              title: AppTranslations.get('scan_artifact', langService.currentLanguage),
              description: langService.isArabic ? 'اكتشف القطع الأثرية' : 'Discover artifacts',
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
