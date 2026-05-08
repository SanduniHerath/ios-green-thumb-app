# GreenThumb - Comprehensive Code Documentation

## Architecture & Design Patterns

GreenThumb follows a modern **MVVM (Model-View-ViewModel)** architecture, optimized for SwiftUI's declarative syntax and reactive data binding.

### 1. Navigation & Routing (`AppRouter.swift`)
The app utilizes a centralized, type-safe navigation system:
- **`AppRouter`**: A `@MainActor` singleton that manages a `NavigationPath`. It decouples view transitions from the UI components.
- **`AppRoute` Enum**: Defines all navigable destinations (e.g., `.plantDetails`, `.expertProfile`, `.bookSession`). This allows for deep linking and programmatic navigation across the app.
- **Environment Injection**: The router is injected as an `@EnvironmentObject` at the app root, making navigation accessible from any view.

### 2. State Management
- **Environment Objects**: Core services and state containers (`AuthViewModel`, `PlantViewModel`, `DiagnoseViewModel`) are initialized in `green_thumb_appApp.swift` and shared globally.
- **Combine Integration**: ViewModels use `@Published` properties to emit changes, which SwiftUI views observe to update automatically.

---

## Data Management & Persistence

### 1. Real-time Database (Firebase Firestore)
- **Structure**: Uses a user-centric subcollection model (`users/{uid}/plants`).
- **Listeners**: Real-time snapshots are attached in `PlantViewModel` to ensure the UI reflects the latest data instantly.

### 2. Local Caching & Offline Support (Core Data)
The app implements a robust **Cache-Aside Strategy** in `Persistence.swift` and `PlantViewModel.swift`:
- **Entity**: `CachedPlant` mirrors the `PlantModel` for local persistence.
- **Synchronization**: Every successful Firestore fetch triggers a background sync to Core Data.
- **Offline Fallback**: If the network is unavailable, the app automatically switches to the Core Data store, ensuring users can always access their garden data.

---

## Advanced iOS Features

### MapKit & Core Location Integration
Located in `Views/Experts/` and `ViewModels/NearbyExpertsMapViewModel.swift`:
- **Interactive Maps**: Displays Agricultural Offices and experts on a native `Map` view.
- **Live Geolocation**: Uses `CLLocationManager` to track the user's position and calculate real-time distances to the nearest support centers.
- **Apple Maps Routing**: Deep links into the official Apple Maps app to provide turn-by-turn driving directions from the user's current location to a selected expert.

### EventKit (Calendar & Reminders)
Implemented in `Helpers/CalendarManager.swift`:
- **Calendar Events**: Users can schedule expert consultations or planting sessions directly into their **iOS Calendar**.
- **System Reminders**: Integrated with the native **Reminders app** to track long-term care tasks.
- **Permission Management**: Handles complex system-level permissions for both calendar and reminder access.

### Local Push Notifications
Managed by `NotificationManager.swift`:
- **Immediate Alerts**: Used for instant feedback (e.g., confirming a new plant addition).
- **Scheduled Reminders**: Supports `UNCalendarNotificationTrigger` and `UNTimeIntervalNotificationTrigger` for watering and fertilizing schedules.
- **Foreground Notifications**: Custom delegate handling allows alerts to appear even when the app is active.

### Biometric Security (Face ID / Touch ID)
Integrated in `AuthViewModel.swift` and `KeychainHelper.swift`:
- **Keychain Storage**: Encrypts and stores user credentials securely upon first login.
- **LocalAuthentication**: Uses the `LAContext` API to verify the user's identity.
- **Seamless Re-auth**: Allows users to bypass manual login by retrieving credentials from the secure enclave after a successful biometric scan.

---

## Media & Networking

### Cloudinary Image Hosting
Located in `Helpers/CloudinaryService.swift`:
- **Unsigned Uploads**: Implements a pure `URLSession` multipart POST request to upload plant images without an SDK dependency.
- **Performance**: Returns a secure CDN URL that is stored in Firestore, optimizing database performance and load times.

---

## Design System & Accessibility

Defined in `DesignSystem.swift`:
- **Premium Aesthetics**: A curated HSL color palette tailored for a premium "garden" feel.
- **Dynamic Type Support**: All fonts use SwiftUI's semantic text styles (e.g., `.custom("Georgia", size: 34, relativeTo: .largeTitle)`), ensuring the app respects user system-wide font size preferences.
- **Accessibility (WCAG)**: Interactive elements maintain a minimum hit target of 44x44 points.

---

## Setup Instructions

1. **Firebase**: Download `GoogleService-Info.plist` and add it to the root directory.
2. **Permissions**: The `Info.plist` must include keys for `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSCalendarsUsageDescription`, and `NSRemindersUsageDescription`.
3. **Environment**: Update Cloudinary credentials in `CloudinaryService.swift`.

