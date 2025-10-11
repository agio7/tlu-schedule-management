# TLU Schedule Management - Lecturer Interface

A Flutter application for managing teaching schedules at Thuy Loi University (TLU). This app provides lecturers with tools to manage their classes, track attendance, and handle leave requests.

## Features

### 🏠 Dashboard
- Overview of today's schedule
- Quick access to ongoing and upcoming classes
- User profile and notifications

### 📅 Calendar/Schedule
- Monthly calendar view
- Filter by subject
- View all lessons with status indicators
- Navigate to lesson details

### 📚 Lesson Details
Three main functionalities for each lesson:

1. **Content Management**
   - Add/edit lesson content
   - Track session progress

2. **Attendance Tracking**
   - Mark student attendance
   - View attendance statistics
   - Export attendance records

3. **Leave Registration**
   - Register for leave
   - Schedule make-up classes
   - Track leave requests

### 👥 Attendance
- Direct access to today's classes
- Quick attendance marking
- Real-time attendance status

### 📊 Reports & Statistics
- Teaching hours tracking
- Leave statistics
- Class completion rates
- Historical data analysis

## Navigation Flow

```
Dashboard
├── Calendar → Lesson List → Lesson Detail
│   ├── Content Tab
│   ├── Attendance Tab
│   └── Leave Registration Tab
├── Attendance → Today's Classes
├── Leave Registration → Form
└── Reports → Statistics
```

## Technical Stack

- **Framework**: Flutter 3.9.0+
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI**: Material Design 3
- **Localization**: Vietnamese (vi)

## Dependencies

- `go_router`: Navigation and routing
- `provider`: State management
- `intl`: Date/time formatting
- `http`: API communication
- `shared_preferences`: Local storage

## Getting Started

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── lesson.dart          # Data models
├── providers/
│   └── lesson_provider.dart # State management
├── screens/
│   ├── dashboard_screen.dart
│   ├── calendar_screen.dart
│   ├── lesson_detail_screen.dart
│   ├── attendance_screen.dart
│   ├── leave_registration_screen.dart
│   └── reports_screen.dart
└── widgets/
    ├── bottom_navigation.dart
    ├── lesson_card.dart
    ├── lesson_content_tab.dart
    ├── attendance_tab.dart
    └── leave_registration_tab.dart
```

## Key Features Implementation

### Lesson Management
- Create, read, update lesson information
- Track lesson status (completed, ongoing, upcoming)
- Manage lesson content and materials

### Attendance System
- Student roster management
- Real-time attendance tracking
- Attendance history and reports

### Leave Management
- Leave request submission
- Make-up class scheduling
- Request status tracking

### Reporting
- Teaching hours calculation
- Attendance statistics
- Leave request analytics

## UI/UX Design

- **Color Scheme**: Purple theme (#6B46C1) with Material Design 3
- **Typography**: Roboto font family
- **Layout**: Responsive design with card-based interface
- **Navigation**: Bottom navigation with 4 main sections

## Future Enhancements

- [ ] Push notifications for class reminders
- [ ] Offline mode support
- [ ] Student photo recognition for attendance
- [ ] Integration with university systems
- [ ] Advanced analytics and reporting
- [ ] Multi-language support

## Contributing

This is a university project for TLU. For contributions or issues, please contact the development team.

## License

This project is developed for educational purposes at Thuy Loi University.