# Atharna - Architecture Plan

## Overview
Bilingual (Arabic/English) mobile app for Egyptian heritage museums with Firebase backend, QR scanning, and booking system.

## Core Features
1. **Bilingual Support**: Arabic & English with auto-detection and manual toggle
2. **Authentication**: Firebase Auth (signup, login, password reset)
3. **Museum Booking System**: Firestore-based with email confirmation
4. **QR Code Scanner**: Artifact information display
5. **Responsive Design**: Egyptian-themed UI (gold, sandstone, papyrus)

## Technical Stack
- **Frontend**: Flutter with RTL/LTR support
- **Backend**: Firebase (Auth, Firestore)
- **Email**: Firebase Functions (booking confirmation)
- **Scanner**: qr_code_scanner package
- **Storage**: Firestore for users, bookings, artifacts

## File Structure (10 files)
```
lib/
├── main.dart                    # App entry, language setup
├── theme.dart                   # Egyptian color palette
├── models/
│   ├── user_model.dart         # User data model
│   ├── booking_model.dart      # Booking data model
│   └── artifact_model.dart     # Artifact data model
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   ├── booking_service.dart    # Firestore booking operations
│   └── language_service.dart   # Language state management
├── utils/
│   └── translations.dart       # Bilingual strings
└── screens/
    ├── splash_screen.dart      # Initial screen with logo
    ├── home_screen.dart        # Pre-login homepage
    ├── about_screen.dart       # About Atharna
    ├── login_screen.dart       # Authentication
    ├── signup_screen.dart      # Registration
    ├── dashboard_screen.dart   # Post-login main navigation
    ├── booking_screen.dart     # Create new booking
    ├── my_bookings_screen.dart # View user bookings
    └── scanner_screen.dart     # QR code scanner
```

## Data Models

### User Model
```dart
- uid: String
- name: String
- email: String
- created_at: DateTime
- updated_at: DateTime
```

### Booking Model
```dart
- id: String
- userId: String
- userName: String
- userEmail: String
- museum: String (bilingual)
- date: DateTime
- time: String
- visitors: int
- bookingCode: String (unique)
- created_at: DateTime
- updated_at: DateTime
```

### Artifact Model
```dart
- id: String
- name: Map<String, String> (en/ar)
- description: Map<String, String> (en/ar)
- dynasty: Map<String, String> (en/ar)
- qrCode: String
- created_at: DateTime
```

## Implementation Steps

### Phase 1: Setup & Infrastructure
1. Update theme.dart with Egyptian color palette (gold #D4AF37, sandstone #C2B280)
2. Add Firebase dependencies and configure
3. Move logo.png to assets/images/
4. Create translation utility with all bilingual strings
5. Implement language service with SharedPreferences

### Phase 2: Authentication
6. Create User, Booking, Artifact models with Firestore serialization
7. Implement AuthService with Firebase Auth
8. Build Splash screen with logo
9. Build Home screen (pre-login)
10. Build About screen
11. Build Login/Signup screens with validation

### Phase 3: Core Features
12. Build Dashboard with bottom navigation
13. Implement BookingService with Firestore operations
14. Build Booking screen with form validation
15. Build My Bookings screen with cancel functionality
16. Integrate qr_code_scanner for Scanner screen
17. Add artifact dummy data display

### Phase 4: Integration & Testing
18. Connect all screens with proper routing
19. Implement Firebase Cloud Function for email sending
20. Test RTL/LTR switching
21. Validate responsive design on different screen sizes
22. Run compile_project to fix any Dart errors

## Key Technical Decisions
- Use Provider for language state management
- SharedPreferences for language persistence
- Firebase Timestamp for all date fields
- UUID for booking codes
- Email sent via Firebase Functions (trigger on Firestore write)

## Firebase Collections
- `users`: User profiles
- `bookings`: Museum reservations
- `artifacts`: Scanned items history
- `emailLogs`: Email delivery tracking

## Permissions Required
- Android: CAMERA, INTERNET
- iOS: NSCameraUsageDescription
