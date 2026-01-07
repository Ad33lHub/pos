# Smart POS & Inventory Management System

A modern Point of Sale (POS) and Full Inventory Management application built with Flutter and PHP backend. Features glassmorphic UI design with dark blue iPhone-style aesthetics, online/offline mode support, and comprehensive inventory management capabilities.

## 📱 Features

### Commit 1 (Current)
- ✅ Modern glassmorphic UI with dark blue gradient backgrounds
- ✅ User authentication (Login/Signup)
- ✅ PHP REST API backend
- ✅ MySQL database integration
- ✅ JWT token-based authentication
- ✅ Form validation
- ✅ Smooth animations and transitions
- ✅ Responsive design

### Upcoming Features
- 🔄 Offline mode with SQLite
- 🔄 Online/Offline sync
- 🔄 Product management
- 🔄 Inventory tracking
- 🔄 Sales & POS system
- 🔄 Customer management
- 🔄 Reports and analytics
- 🔄 Google Drive backup
- 🔄 Data restore functionality

## 🛠️ Technology Stack

### Frontend
- **Flutter** 3.38.4
- **State Management**: Provider
- **Local Storage**: SharedPreferences, SQLite
- **HTTP Client**: http package
- **UI Components**: Custom glassmorphic widgets

### Backend
- **PHP** 7.4+
- **MySQL** 8.0+
- **Authentication**: JWT tokens
- **API Architecture**: REST

## 📋 Prerequisites

- Flutter SDK 3.38.4 or higher
- Dart SDK 3.10.3 or higher
- PHP 7.4 or higher
- MySQL 8.0 or higher
- XAMPP/WAMP or any PHP server
- Android Studio / VS Code
- Git

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd pos
```

### 2. Backend Setup

#### Step 1: Start XAMPP/WAMP
- Start Apache and MySQL services

#### Step 2: Create Database
```bash
# Open phpMyAdmin or use MySQL command line
mysql -u root -p < backend/database/schema.sql
```

Or manually:
1. Open phpMyAdmin (http://localhost/phpmyadmin)
2. Create database `pos_db`
3. Import `backend/database/schema.sql`

#### Step 3: Configure Database
- Update `backend/config/database.php` if your MySQL credentials differ:
```php
private $host = "localhost";
private $db_name = "pos_db";
private $username = "root";
private $password = ""; // Your MySQL password
```

#### Step 4: Deploy Backend
- Copy the `backend` folder to your web server's htdocs/www directory
- Ensure it's accessible at `http://localhost/pos/backend`

### 3. Flutter Setup

#### Step 1: Install Dependencies
```bash
flutter pub get
```

#### Step 2: Update API URL
- Open `lib/services/auth_service.dart`
- Update the `baseUrl` with your backend URL:
```dart
static const String baseUrl = 'http://localhost/pos/backend';
// Or use your IP for physical device testing
// static const String baseUrl = 'http://192.168.1.100/pos/backend';
```

#### Step 3: Run the App
```bash
# For development
flutter run

# For release APK
flutter build apk --release
```

## 📁 Project Structure

```
pos/
├── backend/                    # PHP Backend
│   ├── api/
│   │   └── auth/
│   │       ├── login.php      # Login endpoint
│   │       └── signup.php     # Signup endpoint
│   ├── config/
│   │   └── database.php       # Database configuration
│   ├── models/
│   │   └── User.php           # User model
│   └── database/
│       └── schema.sql         # Database schema
│
├── lib/                        # Flutter App
│   ├── config/
│   │   └── theme.dart         # App theme & colors
│   ├── models/                # Data models
│   ├── screens/
│   │   ├── splash_screen.dart # Splash screen
│   │   ├── login_screen.dart  # Login screen
│   │   └── signup_screen.dart # Signup screen
│   ├── services/
│   │   └── auth_service.dart  # Authentication service
│   ├── widgets/
│   │   ├── glassmorphic_container.dart
│   │   ├── custom_text_field.dart
│   │   └── gradient_button.dart
│   └── main.dart              # App entry point
│
└── README.md
```

## 🎨 Design

The app features a modern glassmorphic design inspired by iPhone aesthetics:
- **Dark blue gradient backgrounds** (similar to iOS)
- **Frosted glass effects** with backdrop blur
- **Smooth animations** and transitions
- **Premium UI components** with gradient buttons
- **Consistent color scheme** throughout the app

### Color Palette
- Primary Dark Blue: #0A1128
- Secondary Dark Blue: #1C2951
- Accent Blue: #3E5C9A
- Light Blue: #6B8DD6

## 🔌 API Endpoints

### Authentication

#### Signup
```http
POST /api/auth/signup.php
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

#### Login
```http
POST /api/auth/login.php
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

## 📱 Screenshots

_Screenshots will be added here_

## 🧪 Testing

### Test Credentials
```
Email: test@example.com
Password: password123
```

### Testing with Postman
1. Import the API endpoints into Postman
2. Test signup endpoint with new user data
3. Test login endpoint with created credentials
4. Verify token is returned

## 👥 Team

- **Developer**: [Your Name]
- **Course**: Mobile Application Development
- **Institution**: [Your Institution]

## 📝 License

This project is created for educational purposes as part of a lab assignment.

## 🚨 Important Notes

- Update the backend URL in `auth_service.dart` before building
- Ensure backend server is running when testing the app
- For physical device testing, use your computer's IP address instead of localhost
- Database credentials are set to default XAMPP values (root with no password)

## 📞 Support

For issues or questions, contact [Your Email]

---

**Version**: 1.0.0 (Commit 1)  
**Last Updated**: January 2026
