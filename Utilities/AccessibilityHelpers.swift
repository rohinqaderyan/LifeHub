//
//  AccessibilityHelpers.swift
//  LifeHub
//
//  Accessibility utilities and extensions for VoiceOver support
//

import SwiftUI

// MARK: - Accessibility Labels

struct AccessibilityLabels {
    
    // Navigation
    static let tabHome = "Home Dashboard Tab"
    static let tabTasks = "Tasks Manager Tab"
    static let tabHabits = "Habit Tracker Tab"
    static let tabMedia = "Media Hub Tab"
    static let tabSettings = "Settings Tab"
    
    // Actions
    static let addTask = "Add new task"
    static let editTask = "Edit task"
    static let deleteTask = "Delete task"
    static let completeTask = "Mark task as complete"
    static let uncompleteTask = "Mark task as incomplete"
    
    static let addHabit = "Add new habit"
    static let completeHabit = "Complete habit for today"
    static let viewHabitDetails = "View habit details and statistics"
    
    // Media
    static let playTrack = "Play track"
    static let pauseTrack = "Pause track"
    static let nextTrack = "Skip to next track"
    static let previousTrack = "Go to previous track"
    static let shuffleTracks = "Toggle shuffle mode"
    static let repeatMode = "Change repeat mode"
    
    // Settings
    static let changeTheme = "Change app theme"
    static let toggleDarkMode = "Toggle dark mode"
    static let exportData = "Export all data"
    static let importData = "Import data from backup"
}

// MARK: - Accessibility Hints

struct AccessibilityHints {
    
    // Tasks
    static let taskRow = "Double tap to view details, swipe right to complete, swipe left for options"
    static let addTaskButton = "Double tap to open task creation form"
    static let taskPriority = "Double tap to change priority level"
    
    // Habits
    static let habitCard = "Double tap to mark as complete for today"
    static let habitStreak = "Current streak of consecutive completions"
    static let habitBadges = "Achievements earned for this habit"
    
    // Media
    static let playbackControl = "Double tap to toggle playback"
    static let trackProgress = "Adjust to seek through track"
    
    // General
    static let searchField = "Enter text to filter results"
    static let themeSelector = "Double tap to apply this theme"
}

// MARK: - Accessibility Values

struct AccessibilityValues {
    
    static func taskPriority(_ priority: String) -> String {
        return "Priority: \(priority)"
    }
    
    static func taskDueDate(_ date: Date?) -> String {
        guard let date = date else { return "No due date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Due on \(formatter.string(from: date))"
    }
    
    static func habitStreak(_ streak: Int) -> String {
        return "\(streak) day\(streak == 1 ? "" : "s") streak"
    }
    
    static func habitCompletionRate(_ rate: Double) -> String {
        return "\(Int(rate * 100)) percent completion rate"
    }
    
    static func trackProgress(_ current: TimeInterval, total: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let currentStr = formatter.string(from: current) ?? "0:00"
        let totalStr = formatter.string(from: total) ?? "0:00"
        
        return "\(currentStr) of \(totalStr)"
    }
}

// MARK: - View Extension for Accessibility

extension View {
    
    /// Apply comprehensive accessibility modifiers
    func accessible(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .if(value != nil) { view in
                view.accessibilityValue(value!)
            }
            .accessibilityAddTraits(traits)
    }
    
    /// Mark as button for accessibility
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self.accessible(label: label, hint: hint, traits: .isButton)
    }
    
    /// Mark as header for accessibility
    func accessibleHeader(label: String) -> some View {
        self.accessible(label: label, traits: .isHeader)
    }
    
    /// Mark as image for accessibility
    func accessibleImage(label: String, isDecorative: Bool = false) -> some View {
        if isDecorative {
            return self.accessibilityHidden(true)
        } else {
            return self.accessible(label: label, traits: .isImage)
        }
    }
    
    /// Group accessibility elements
    func accessibilityGroup(label: String? = nil, hint: String? = nil) -> some View {
        Group {
            if let label = label {
                self.accessibilityElement(children: .combine)
                    .accessibilityLabel(label)
                    .if(hint != nil) { view in
                        view.accessibilityHint(hint!)
                    }
            } else {
                self.accessibilityElement(children: .combine)
            }
        }
    }
    
    /// Add custom accessibility action
    func accessibilityCustomAction(
        named name: String,
        action: @escaping () -> Void
    ) -> some View {
        self.accessibilityAction(named: name) {
            action()
        }
    }
}

// MARK: - Accessibility Announcement Helper

class AccessibilityAnnouncer {
    
    static func announce(_ message: String, delay: Double = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    static func announceScreenChange(to view: String) {
        UIAccessibility.post(notification: .screenChanged, argument: view)
    }
    
    static func announceLayoutChange() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
    
    static func announcePageChanged() {
        UIAccessibility.post(notification: .pageScrolled, argument: nil)
    }
}

// MARK: - Accessibility Modifier for Task Priority

struct TaskAccessibility: ViewModifier {
    let task: Task
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    func body(content: Content) -> some View {
        content
            .accessible(
                label: taskLabel(),
                hint: AccessibilityHints.taskRow,
                value: taskValue()
            )
            .accessibilityCustomAction(named: "Complete") {
                onComplete()
            }
            .accessibilityCustomAction(named: "Delete") {
                onDelete()
            }
    }
    
    private func taskLabel() -> String {
        return task.title
    }
    
    private func taskValue() -> String {
        var components: [String] = []
        
        components.append(AccessibilityValues.taskPriority(task.priority.rawValue))
        
        if let dueDate = task.dueDate {
            components.append(AccessibilityValues.taskDueDate(dueDate))
        }
        
        if task.isCompleted {
            components.append("Completed")
        } else {
            components.append("Not completed")
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - Accessibility Modifier for Habit

struct HabitAccessibility: ViewModifier {
    let habit: Habit
    let onComplete: () -> Void
    
    func body(content: Content) -> some View {
        content
            .accessible(
                label: habit.name,
                hint: AccessibilityHints.habitCard,
                value: habitValue()
            )
            .accessibilityCustomAction(named: "Complete for today") {
                onComplete()
            }
    }
    
    private func habitValue() -> String {
        var components: [String] = []
        
        components.append(AccessibilityValues.habitStreak(habit.currentStreak))
        components.append(AccessibilityValues.habitCompletionRate(habit.completionRate))
        
        if habit.isCompletedToday {
            components.append("Completed today")
        } else {
            components.append("Not yet completed today")
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - Accessibility Settings

class AccessibilitySettings: ObservableObject {
    @Published var preferredContentSizeCategory: ContentSizeCategory = .medium
    @Published var reduceMotion: Bool = false
    @Published var reduceTransparency: Bool = false
    @Published var boldText: Bool = false
    @Published var buttonShapes: Bool = false
    
    init() {
        updateSettings()
        
        // Observe accessibility notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UIAccessibility.boldTextStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UIAccessibility.buttonShapesEnabledStatusDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func updateSettings() {
        reduceMotion = UIAccessibility.isReduceMotionEnabled
        reduceTransparency = UIAccessibility.isReduceTransparencyEnabled
        boldText = UIAccessibility.isBoldTextEnabled
        buttonShapes = UIAccessibility.buttonShapesEnabled
    }
    
    var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    var isSwitchControlRunning: Bool {
        UIAccessibility.isSwitchControlRunning
    }
    
    var shouldUseReducedMotion: Bool {
        reduceMotion
    }
    
    var shouldUseReducedTransparency: Bool {
        reduceTransparency
    }
}

// MARK: - Conditional Animation Helper

extension View {
    func conditionalAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V,
        respectReduceMotion: Bool = true
    ) -> some View {
        if respectReduceMotion && UIAccessibility.isReduceMotionEnabled {
            return self
        } else {
            return self.animation(animation, value: value)
        }
    }
}

// MARK: - Color Contrast Helper

extension Color {
    /// Check if color has sufficient contrast for accessibility
    func hasContrast(with otherColor: Color, ratio: Double = 4.5) -> Bool {
        let luminance1 = self.relativeLuminance()
        let luminance2 = otherColor.relativeLuminance()
        
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        
        let contrast = (lighter + 0.05) / (darker + 0.05)
        return contrast >= ratio
    }
    
    private func relativeLuminance() -> Double {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0]
        
        let r = components[0]
        let g = components.count > 1 ? components[1] : components[0]
        let b = components.count > 2 ? components[2] : components[0]
        
        let rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4)
        let gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4)
        let bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4)
        
        return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear
    }
}
