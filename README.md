# LifeHub 🚀

A modern, feature-rich iOS application built with SwiftUI showcasing the latest iOS development technologies and design trends.

## 📱 Features

### 🏠 Home Dashboard
- **Dynamic Widgets**: Weather, tasks, habits, calendar, news, and daily quotes
- **Quick Stats**: Overview of pending tasks, active streaks, and earned badges
- **Animated Transitions**: Smooth, spring-based animations throughout
- **Glassmorphism Design**: Modern, translucent card designs

### ✅ Task Manager
- **Complete Task Management**: Add, edit, delete tasks with full CRUD operations
- **Priority Levels**: Low, Medium, High, and Urgent with color coding
- **Swipe Gestures**: Quick actions for editing and deleting tasks
- **Due Dates**: Set due dates with calendar picker
- **Local Notifications**: Get reminded about upcoming tasks
- **Smart Filtering**: Filter by priority and completion status
- **Search**: Full-text search across task titles and descriptions

### 🔥 Habit Tracker
- **Animated Progress Rings**: Visual representation of daily completion
- **Streak Tracking**: Current and longest streak counters with flame icons
- **Gamification System**: 
  - Earn badges (First Step, Week Warrior, Month Master, Centurion, Half Century)
  - Track total completions and success rates
- **Weekly Progress Charts**: Bar charts showing 7-day activity using Swift Charts
- **Custom Icons & Colors**: Personalize each habit with icons and color themes
- **Real-time Updates**: Instant UI updates using Combine framework

### 🎵 Media Hub
- **Music Player**: 
  - Now playing card with album art
  - Playback controls (play, pause, skip)
  - Progress bar with time tracking
  - Playlist management
- **Photo Gallery**:
  - Grid layout with thumbnails
  - Pinch-to-zoom support
  - Photo filters (Original, Sepia, Mono, Noir, Vibrant)
  - Full-screen viewing
- **Video Player**:
  - Video playback with controls
  - Full-screen mode
  - Picture-in-picture ready (AVKit)

### ⚙️ Settings
- **Theme Customization**: 6 beautiful gradient themes
  - Ocean Wave
  - Sunset Glow
  - Forest Green
  - Lavender Dream
  - Neon Nights
  - Cherry Blossom
- **Dark/Light Mode**: System-wide appearance control
- **Profile Customization**: Edit username and bio
- **Notification Preferences**: Toggle push notifications
- **Haptic Feedback**: Enable/disable haptic responses

### 🎮 Fun Extras
- **Tic-Tac-Toe Game**: Classic game with smooth animations
- **Daily Quotes Generator**: Inspirational quotes with beautiful typography
- **AI Chatbot**: Interactive assistant for productivity tips

## 🛠 Technical Stack

### Frameworks & Technologies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **Charts**: Native charting framework for data visualization
- **AVKit**: Video and audio playback
- **UserNotifications**: Local push notifications
- **UserDefaults**: Lightweight data persistence

### Architecture & Patterns
- **MVVM Architecture**: Clean separation of concerns
- **ObservableObject**: State management with @Published properties
- **Environment Objects**: Dependency injection across views
- **Modular Code Structure**: Organized managers and views

### Design Patterns
- **Glassmorphism**: Translucent, layered card designs
- **Gradient Backgrounds**: Beautiful color transitions
- **Spring Animations**: Natural, physics-based movements
- **Micro-interactions**: Subtle feedback on user actions
- **Adaptive Layouts**: Responsive design for iPhone and iPad

## 📂 Project Structure

```
LifeHub/
├── LifeHubApp.swift          # App entry point
├── ContentView.swift          # Main tab navigation
├── Info.plist                 # App configuration
│
├── Managers/
│   ├── ThemeManager.swift     # Theme and color management
│   ├── TaskManager.swift      # Task CRUD operations
│   ├── HabitManager.swift     # Habit tracking & gamification
│   └── MediaManager.swift     # Media playback management
│
└── Views/
    ├── HomeDashboardView.swift    # Dashboard with widgets
    ├── TaskManagerView.swift      # Task management interface
    ├── HabitTrackerView.swift     # Habit tracking with charts
    ├── MediaHubView.swift         # Media player & gallery
    └── SettingsView.swift         # Settings & fun extras
```

## 🎨 Design Philosophy

### Modern UI/UX
- **Trending Designs**: Implements glassmorphism and modern gradient aesthetics
- **Smooth Animations**: Spring-based animations with carefully tuned physics
- **Gesture Navigation**: Intuitive swipe gestures and tap interactions
- **Accessibility**: Support for Dynamic Type and VoiceOver
- **Performance**: Lazy loading and efficient rendering

### Color Themes
Each theme features:
- Unique accent color
- Gradient pair for backgrounds
- Consistent color psychology
- Dark/Light mode compatibility

## 🚀 Getting Started

### Requirements
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation
1. Open the project in Xcode
2. Select a target device or simulator
3. Press Cmd+R to build and run

### First Run
- Grant notification permissions for task reminders
- Explore the dashboard and create your first task
- Start a habit and begin your streak
- Customize the theme in Settings

## ✨ Key Features Highlights

### Animations & Effects
- Spring animations with custom dampening
- Glassmorphic cards with blur effects
- Progress ring animations with trim effect
- Scale and opacity transitions
- Haptic feedback on interactions

### Data Persistence
- Tasks saved to UserDefaults
- Habits with completion history
- Theme preferences
- User profile information
- Playlist and media data

### Notifications
- Local push notifications for tasks
- Background notification scheduling
- Calendar-based triggers
- Custom notification content

## 🎯 Use Cases

Perfect for:
- **Productivity Enthusiasts**: Manage tasks and build habits
- **Students**: Track study habits and assignments
- **Fitness Tracking**: Monitor workout and health habits
- **Personal Development**: Build consistent routines
- **Entertainment**: Listen to music, view photos, play games

## 📝 Code Quality

- **Well Documented**: Clear comments explaining complex logic
- **Type Safe**: Leverages Swift's strong type system
- **Error Handling**: Graceful handling of edge cases
- **Modular**: Easy to extend and maintain
- **Best Practices**: Follows Apple's Human Interface Guidelines

## 🔮 Future Enhancements

Potential additions:
- Core Data integration for advanced persistence
- CloudKit sync across devices
- Widget extensions for home screen
- Apple Watch companion app
- Siri Shortcuts integration
- HealthKit integration for fitness habits
- Calendar sync for tasks
- Social sharing features

## 📄 License

This is a demonstration project created for educational purposes.

## 👨‍💻 Author & Developer - Rohin Qaderyan

Built with ❤️ using SwiftUI and modern iOS technologies.

---

**LifeHub** - Your all-in-one productivity companion! 🌟

---

**Developer** - Rohin Qaderyan
