# 🏨 HotelSpot – Smart Hotel Booking App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-Programming-blue?logo=dart)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-purple)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green)
![Platform](https://img.shields.io/badge/Platform-Android-lightgrey)
![License](https://img.shields.io/badge/License-MIT-orange)

---

## 📱 Overview

**HotelSpot** is a modern **Flutter-based hotel booking mobile application** designed to help users easily discover, browse, and book hotels.

The application follows **Clean Architecture** and uses **BLoC (Business Logic Component)** for state management to ensure scalability, maintainability, and a smooth user experience.

The platform focuses on:

- Fast hotel discovery
- Offline data support
- Clean and scalable architecture
- Smooth user interface

---

## ✨ Features

### 👤 User Features

- 🔐 User Authentication (Login & Signup)
- 🔎 Search and browse hotels
- 📄 View detailed hotel information
- ❤️ Add hotels to favorites
- 📅 Book hotels easily
- 📶 Offline access to favorites and history

### 🛠 Admin Features

- Manage hotel listings
- Update hotel information
- Monitor bookings

---

## 🧠 Architecture

HotelSpot follows **Clean Architecture**, which separates the application into three main layers.

```
Presentation Layer
    ↓
Domain Layer
    ↓
Data Layer
```

### 📦 Project Structure

```
lib/
│
├── presentation/        # UI Screens, Widgets, BLoC
│
├── domain/              # Entities, Use Cases, Business Logic
│
├── data/                # API Services, Models, Repositories
│
├── core/                # Constants, utilities, helpers
│
└── main.dart
```

### Benefits of Clean Architecture

- Scalable codebase
- Easy testing
- Better separation of concerns
- Maintainable large applications

---

## 🔄 State Management

HotelSpot uses **BLoC (Business Logic Component)** for state management.

### Why BLoC?

- Predictable **Event → State** flow
- Clear separation between UI and business logic
- Easy debugging and testing
- Scalable for complex applications

Example flow:

```
User Action → Event → BLoC → State Update → UI Rebuild
```

---

## 🛠 Tech Stack

| Technology | Purpose                           |
| ---------- | --------------------------------- |
| Flutter    | Cross-platform mobile development |
| Dart       | Programming language              |
| BLoC       | State management                  |
| Hive       | Local offline database            |
| REST API   | Backend communication             |
| MongoDB    | Data storage                      |

---

## ⚙️ Installation

### 1️⃣ Clone the repository

```bash
git clone https://github.com/asrim10/hotelspot.git
```

### 2️⃣ Navigate to project

```bash
cd hotelspot
```

### 3️⃣ Install dependencies

```bash
flutter pub get
```

### 4️⃣ Run the app

```bash
flutter run
```

---

## 📦 Key Dependencies

```
flutter_bloc
equatable
http
hive
hive_flutter
get_it
```

---

## 📊 System Flow

```
User
  ↓
Flutter UI
  ↓
BLoC State Management
  ↓
Repository Layer
  ↓
API Services
  ↓
Database (MongoDB)
```

---

## 🚀 Future Improvements

- 🔔 Push notifications
- 💳 Secure payment integration
- 📍 Location-based hotel search
- 🤖 AI-based hotel recommendations
- 💬 In-app chat with hotels

---

## 👨‍💻 Author

**Asrim Suwal**

Computer Science Student  
Mobile & Full Stack Developer

GitHub  
https://github.com/asrim10

---

## ⭐ Support

If you found this project useful, please **give it a star ⭐ on GitHub** to support the project.

---

## 📜 License

This project is licensed under the **MIT License**.
