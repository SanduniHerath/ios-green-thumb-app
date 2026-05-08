# GreenThumb - Your Personal Garden Assistant

GreenThumb is a modern iOS application designed to help gardeners of all levels manage their plants, diagnose issues, and connect with experts. Built with **SwiftUI**, **Firebase**, and **Core Data**, it offers a seamless experience both online and offline.

---

## Advanced Features

GreenThumb leverages the full power of the iOS ecosystem to provide a seamless and secure experience:

- **🔐 Biometric Authentication (Face ID)**: Secure your garden data with native Face ID/Touch ID integration, powered by the iOS Keychain for encrypted credential storage.
- **📍 Intelligent Mapping (MapKit)**: Discover nearby Agricultural Offices and experts with real-time distance calculations and integrated Apple Maps routing for turn-by-turn directions.
- **📅 System Integration (EventKit)**: Sync your gardening schedule directly with the native iOS Calendar and Reminders apps.
- **🔔 Proactive Reminders**: Never miss a watering or fertilizing session with scheduled local push notifications that work even when you're offline.
- **💾 Robust Offline Support (Core Data)**: A sophisticated "Cache-Aside" architecture ensures your data is always available, automatically syncing between Firebase Firestore and local Core Data.
- **📸 High-Performance Media**: Integrated Cloudinary support for fast, reliable image uploads and CDN-backed delivery.
- **♿ Fully Accessible**: Supports Dynamic Type, VoiceOver, and premium design standards for an inclusive user experience.

---

## 🛠 Tech Stack

- **UI**: SwiftUI (Reactive & Declarative)
- **Backend**: Firebase Firestore (Real-time NoSQL)
- **Persistence**: Core Data (Local Cache)
- **Security**: LocalAuthentication & Keychain
- **Mapping**: MapKit & Core Location
- **Productivity**: EventKit (Calendar/Reminders)
- **Notifications**: UserNotifications Framework
- **Media**: Cloudinary REST API

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Firebase Project & `GoogleService-Info.plist`

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/SanduniHerath/gt-app.git
   cd green_thumb_app
   ```

2. **Setup Firebase**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add an iOS app and download the `GoogleService-Info.plist`.
   - Place `GoogleService-Info.plist` in the `GreenThumb/` directory.

3. **Configure Cloudinary**:
   - Open `GreenThumb/Helpers/CloudinaryService.swift`.
   - Update `cloudName` and `uploadPreset` with your Cloudinary credentials.

4. **Build and Run**:
   - Open `GreenThumb.xcodeproj` in Xcode.
   - Select your target device/simulator and press `Cmd + R`.

---

## 🛠 Tech Stack

- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Backend**: Firebase (Auth, Firestore)
- **Persistence**: Core Data (Local Cache)
- **Image Hosting**: Cloudinary
- **Biometrics**: LocalAuthentication
- **Storage**: Keychain

---

## 📖 Documentation

For a detailed technical breakdown of the architecture, data layer, and advanced system integrations, please refer to the [Full Code Documentation](Code_documentation.md).




