# Ayojana Hub

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A modern event planning and vendor management platform built with Flutter. Connect event organizers with service vendors through a competitive proposal system.

---

## 🎯 About

Ayojana Hub is a mobile-first marketplace that streamlines event planning:
- **Customers** create events and receive competitive proposals from vendors
- **Vendors** discover event opportunities and submit service proposals
- **Admin** manages users, analytics, and platform operations

---

## ✨ Key Features

### Customers
- Create events with automatic service matching
- Browse and compare vendor proposals
- Accept proposals and manage bookings
- Track event history and notifications

### Vendors
- Discover matching event opportunities
- Submit competitive proposals
- Manage bookings and track proposals
- Maintain vendor profile and services

### Admin
- Manage users (customers, vendors, admins)
- View analytics and platform metrics
- Monitor bookings and events
- Manage activity logs

### General
- Real-time notifications
- User activity tracking
- Responsive design (Android/iOS)
- Smooth animations and modern UI

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0.0+
- Dart 3.0.0+
- Firebase project
- Git

### Installation

1. **Clone Repository**
```bash
git clone https://github.com/pramod729/AyojanaHub.git
cd AyojanaHub
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android and iOS apps
   - Download configuration files:
     - `google-services.json` (Android) → `android/app/`
     - `GoogleService-Info.plist` (iOS) → `ios/Runner/`

4. **Run App**
```bash
flutter run
```

---

## 🏗 Architecture

### User Roles
- **Customer**: Creates events, receives proposals, manages bookings
- **Vendor**: Submits proposals, manages services, tracks bookings
- **Admin**: Manages platform, users, and analytics

### Data Models
- **User**: Authentication, profile, role management
- **Event**: Event details with required services
- **Proposal**: Vendor proposals for events
- **Booking**: Confirmed bookings linking customers and vendors
- **Notification**: System notifications for users

### Firebase Collections
```
users/          → User profiles and roles
events/         → Event listings
proposals/      → Vendor proposals
bookings/       → Confirmed bookings
notifications/  → User notifications
activityLogs/   → Activity tracking
```

---

## 🛠 Tech Stack

**Frontend**
- Flutter & Dart
- Provider (state management)
- Material Design 3

**Backend**
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

**UI Components**
- Google Fonts
- Custom theme system
- Material icons

---

## 📁 Project Structure

```
lib/
├── models/              # Data models (User, Event, Booking, etc.)
├── providers/           # State management (Auth, Booking, etc.)
├── screens/             # UI screens
├── services/            # API and service classes
├── theme/               # App theme and styling
└── main.dart           # App entry point
```

---

## 🔄 User Workflows

### Customer Flow
1. Register → Create Event → Vendors Submit Proposals → Accept Best Proposal → Booking Confirmed

### Vendor Flow
1. Register → Setup Profile → Browse Opportunities → Submit Proposal → Await Decision → Confirmed Booking

### Auto-Matching
When event is created, system automatically notifies matching vendors based on service categories.

---

## 📱 Main Screens

**Authentication**: Login, Register, Forgot Password

**Customer**: Home, Create Event, My Events, My Bookings, Profile

**Vendor**: Dashboard, Opportunities, My Proposals, My Bookings, Profile

**Admin**: Dashboard, Users, Vendors, Bookings, Events, Analytics

**Shared**: Notifications, Help & Support, About, AI Assistant

---

## 🔐 Security

- Firebase Authentication for secure login
- Role-based access control (RBAC)
- Firestore Security Rules
- Data validation on client and server

---

## 📋 License

MIT License - Building an open, collaborative event platform

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---


Made with ❤️ using Flutter
