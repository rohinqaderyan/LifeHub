# LifeHub - Developer Guide

## 🏗️ Architecture Overview

### Manager Classes (ObservableObject)

#### ThemeManager
**Purpose**: Manages app-wide theming and appearance

**Properties**:
- `currentTheme: AppTheme` - Selected theme
- `colorScheme: ColorScheme?` - Dark/Light mode
- `isDarkMode: Bool` - Toggle state
- `themes: [AppTheme]` - Available themes

**Key Methods**:
- `selectTheme(_ theme: AppTheme)` - Change current theme
- `savePreferences()` - Persist to UserDefaults

**Themes**:
1. Ocean Wave (Blue gradient)
2. Sunset Glow (Orange gradient)
3. Forest Green (Green gradient)
4. Lavender Dream (Purple gradient)
5. Neon Nights (Cyan gradient)
6. Cherry Blossom (Pink gradient)

---

#### TaskManager
**Purpose**: Complete task lifecycle management

**Properties**:
- `tasks: [Task]` - All tasks
- `searchText: String` - Search filter
- `filterPriority: TaskPriority?` - Priority filter
- `showCompletedTasks: Bool` - Visibility toggle

**Key Methods**:
- `addTask(_ task: Task)` - Create new task
- `updateTask(_ task: Task)` - Edit existing task
- `deleteTask(_ task: Task)` - Remove task
- `toggleTaskCompletion(_ task: Task)` - Mark complete/incomplete
- `scheduleNotification(for task: Task)` - Set reminder

**Task Properties**:
- Title, description, priority (Low/Medium/High/Urgent)
- Due date, created date, completion status
- Tags support for categorization

---

#### HabitManager
**Purpose**: Habit tracking with gamification

**Properties**:
- `habits: [Habit]` - All habits
- `selectedHabit: Habit?` - Currently viewing

**Key Methods**:
- `addHabit(_ habit: Habit)` - Create habit
- `completeHabit(_ habit: Habit)` - Mark today's completion
- `updateStreak(for habit: inout Habit)` - Calculate streaks
- `checkAndAwardBadges(for habit: inout Habit)` - Badge system
- `getWeeklyProgress(for habit: Habit) -> [Int]` - Chart data

**Habit Properties**:
- Name, description, icon, color
- Goal, frequency (Daily/Weekly/Custom)
- Completions array, current/longest streak
- Total completions, badges earned

**Badge Types**:
- First Step (1 completion)
- Week Warrior (7-day streak)
- Month Master (30-day streak)
- Centurion (100-day streak)
- Half Century (50 completions)

---

#### MediaManager
**Purpose**: Media playback and library management

**Properties**:
- `playlists: [Playlist]` - Music playlists
- `currentTrack: MediaTrack?` - Now playing
- `isPlaying: Bool` - Playback state
- `currentTime: TimeInterval` - Progress
- `photos: [PhotoItem]` - Photo gallery

**Key Methods**:
- `playTrack(_ track: MediaTrack)` - Start playback
- `pauseTrack()` / `resumeTrack()` - Control playback
- `skipForward()` / `skipBackward()` - Navigation
- `createPlaylist(name: String)` - New playlist

---

## 📱 View Architecture

### Navigation Structure
```
ContentView (TabView)
├── HomeDashboardView (Tab 1)
├── TaskManagerView (Tab 2)
├── HabitTrackerView (Tab 3)
├── MediaHubView (Tab 4)
└── SettingsView (Tab 5)
```

### HomeDashboardView Components
- **Greeting Header**: Dynamic based on time of day
- **Quick Stats Row**: Tasks, Streaks, Badges counters
- **Widget Grid**: Weather, Tasks, Habits, Quote, Calendar, News
- **Widgets**: Modular, reusable components

### TaskManagerView Components
- **Search Bar**: Full-text search
- **Filter Chips**: Priority-based filtering
- **Task List**: ScrollView with LazyVStack
- **TaskRowView**: Swipeable row with actions
- **AddTaskView**: Sheet for creating tasks
- **EditTaskView**: Sheet for editing tasks

**Swipe Gestures**:
- Swipe left to reveal Delete (red) and Edit (blue) actions
- DragGesture with offset tracking
- Spring animations on state changes

### HabitTrackerView Components
- **Overall Stats Card**: Total habits, today's count, best streak
- **Habits Grid**: 2-column LazyVGrid
- **HabitCard**: Progress ring, icon, streak, complete button
- **HabitDetailView**: Full stats, charts, badges
- **Weekly Progress Chart**: Bar chart using Swift Charts
- **Badges Section**: Achievement display

**Progress Ring Animation**:
```swift
Circle()
    .trim(from: 0, to: habit.isCompletedToday ? 1 : 0)
    .stroke(Color(hex: habit.color), style: StrokeStyle(lineWidth: 8, lineCap: .round))
    .rotationEffect(.degrees(-90))
    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.isCompletedToday)
```

### MediaHubView Components
- **Segmented Control**: Music / Photos / Videos
- **TabView**: Page-style content switching
- **MusicPlayerView**: Now playing card, playlists
- **PhotoGalleryView**: Grid layout with thumbnails
- **PhotoDetailView**: Full-screen with pinch-to-zoom
- **VideoPlayerView**: Video cards with AVKit integration

**Photo Filters**:
- Original, Sepia, Mono, Noir, Vibrant
- Applied via CoreImage filters (placeholder implementation)

### SettingsView Components
- **Profile Section**: Avatar, username, bio editor
- **Appearance Section**: Theme selector, dark mode
- **Notifications Section**: Permission toggles
- **Privacy Section**: Links to policies
- **Fun Extras Section**: Games, quotes, chatbot
- **About Section**: Version, build info

---

## 🎨 Design System

### Glassmorphism Modifier
```swift
.glassmorphic()
```
Creates translucent, layered cards with:
- .ultraThinMaterial background
- Shadow with opacity based on color scheme
- Rounded corners (20pt radius)

### Animation Standards
```swift
.spring(response: 0.3, dampingFraction: 0.7) // Default
.spring(response: 0.4, dampingFraction: 0.8) // Slower
.spring(response: 0.6, dampingFraction: 0.7) // Progress rings
```

### Color Usage
- **Accent Colors**: From selected theme
- **Gradients**: Theme gradient for backgrounds
- **Priority Colors**: 
  - Low: Green
  - Medium: Blue
  - High: Orange
  - Urgent: Red

### Typography
- **Title**: .title, .title2, .title3
- **Headline**: Bold, for section headers
- **Body**: Default text
- **Subheadline**: Secondary info
- **Caption**: Smallest text

---

## 💾 Data Persistence

### UserDefaults Keys
- `"selectedTheme"` - Theme ID
- `"isDarkMode"` - Boolean
- `"savedTasks"` - JSON encoded [Task]
- `"savedHabits"` - JSON encoded [Habit]
- `"username"` - String
- `"bio"` - String

### Data Models (Codable)
All models conform to:
- `Identifiable` - Unique UUID
- `Codable` - JSON serialization

**Encoding**:
```swift
if let encoded = try? JSONEncoder().encode(data) {
    UserDefaults.standard.set(encoded, forKey: key)
}
```

**Decoding**:
```swift
if let data = UserDefaults.standard.data(forKey: key),
   let decoded = try? JSONDecoder().decode([Model].self, from: data) {
    items = decoded
}
```

---

## 🔔 Notifications

### Setup
```swift
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
```

### Scheduling
```swift
let content = UNMutableNotificationContent()
content.title = "Task Due: \(task.title)"
content.body = task.description
content.sound = .default

let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
UNUserNotificationCenter.current().add(request)
```

### Canceling
```swift
UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
```

---

## 📊 Charts Integration

### Bar Chart Example
```swift
Chart {
    ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, value in
        BarMark(
            x: .value("Day", dayLabel(for: index)),
            y: .value("Completions", value)
        )
        .foregroundStyle(Color(hex: habit.color).gradient)
        .cornerRadius(4)
    }
}
.frame(height: 200)
```

### Data Preparation
```swift
func getWeeklyProgress(for habit: Habit) -> [Int] {
    let calendar = Calendar.current
    let today = Date()
    var progress: [Int] = []
    
    for i in 0..<7 {
        if let day = calendar.date(byAdding: .day, value: -6 + i, to: today) {
            let completionsOnDay = habit.completions.filter { 
                calendar.isDate($0, inSameDayAs: day) 
            }.count
            progress.append(completionsOnDay)
        }
    }
    
    return progress
}
```

---

## 🎮 Interactive Features

### Swipe Gestures (Tasks)
```swift
.gesture(
    DragGesture()
        .onChanged { gesture in
            if gesture.translation.width < 0 {
                offset = gesture.translation.width
            }
        }
        .onEnded { gesture in
            withAnimation(.spring()) {
                if gesture.translation.width < -100 {
                    offset = -160 // Show actions
                } else {
                    offset = 0 // Reset
                }
            }
        }
)
```

### Pinch-to-Zoom (Photos)
```swift
.gesture(
    MagnificationGesture()
        .onChanged { value in
            scale = lastScale * value
        }
        .onEnded { _ in
            lastScale = scale
            if scale < 1 {
                withAnimation {
                    scale = 1
                    lastScale = 1
                }
            }
        }
)
```

### Haptic Feedback
```swift
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)
```

---

## 🚀 Performance Optimization

### Lazy Loading
- Use `LazyVStack` and `LazyVGrid` for large lists
- Only render visible items
- Smooth scrolling performance

### Animation Optimization
- Use `.animation(_:value:)` instead of implicit animations
- Limit animation duration and complexity
- Use `.drawingGroup()` for complex drawings

### State Management
- Use `@Published` for reactive updates
- Minimize view re-renders with `@State` locality
- Share state via `@EnvironmentObject`

---

## 🧪 Testing Recommendations

### Unit Tests
- Test manager logic independently
- Mock UserDefaults for persistence tests
- Validate streak calculations
- Test badge award conditions

### UI Tests
- Test navigation flows
- Verify swipe gestures work
- Check theme switching
- Test form validation

### Edge Cases
- Empty states (no tasks, habits)
- Maximum values (very long streaks)
- Date boundaries (midnight crossover)
- Notification permissions denied

---

## 🔧 Customization Guide

### Adding a New Theme
```swift
AppTheme(
    id: "custom", 
    name: "Custom Theme", 
    accentColorHex: "FF00FF", 
    gradientStartHex: "FF0000", 
    gradientEndHex: "00FF00"
)
```

### Adding a New Badge
```swift
if habit.currentStreak == 365 && !existingBadgeNames.contains("Year Champion") {
    newBadges.append(Habit.Badge(
        name: "Year Champion", 
        icon: "star.circle.fill", 
        earnedAt: Date()
    ))
}
```

### Adding a New Widget
1. Create widget view conforming to `View`
2. Add to `DashboardWidget` enum
3. Add case in `widgetView(for:)` switch
4. Widget automatically appears in grid

---

## 📱 iOS Compatibility

### Minimum Requirements
- iOS 17.0+ (for Swift Charts)
- Swift 5.9+
- Xcode 15.0+

### Framework Availability
- SwiftUI: iOS 13.0+
- Combine: iOS 13.0+
- Charts: iOS 16.0+
- AVKit: iOS 2.0+
- UserNotifications: iOS 10.0+

### Device Support
- iPhone (all models with iOS 17+)
- iPad (optimized with adaptive layouts)
- Portrait and landscape orientations

---

## 🐛 Common Issues & Solutions

### Issue: Themes not persisting
**Solution**: Check UserDefaults keys match exactly

### Issue: Notifications not working
**Solution**: Verify Info.plist has `NSUserNotificationsUsageDescription`

### Issue: Charts not displaying
**Solution**: Ensure iOS 17+ deployment target and import Charts framework

### Issue: Swipe gestures conflicting
**Solution**: Use `.gesture(_:including:)` to control gesture priority

---

## 🎯 Best Practices

1. **State Management**: Keep state as local as possible
2. **Reusability**: Extract repeated UI into components
3. **Documentation**: Comment complex logic
4. **Naming**: Use clear, descriptive names
5. **Error Handling**: Always handle optional unwrapping
6. **Animations**: Use consistent timing across app
7. **Accessibility**: Support Dynamic Type and VoiceOver
8. **Performance**: Profile with Instruments

---

## 📚 Learning Resources

### SwiftUI
- Apple's SwiftUI Tutorials
- WWDC SwiftUI sessions
- Hacking with Swift tutorials

### Combine
- Using Combine book
- Apple's Combine documentation
- Reactive programming patterns

### Charts
- Swift Charts documentation
- WWDC 2022: Hello Swift Charts
- Data visualization best practices

---

**Happy Coding! 🎉**
