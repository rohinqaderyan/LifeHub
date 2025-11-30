//
//  HabitManager.swift
//  LifeHub
//
//  Manages habits with streak tracking and gamification
//

import SwiftUI
import Combine

// Habit model
struct Habit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var icon: String
    var color: String
    var goal: Int // Daily goal
    var frequency: HabitFrequency
    var createdAt: Date
    var completions: [Date] // Dates when habit was completed
    var currentStreak: Int
    var longestStreak: Int
    var totalCompletions: Int
    var badges: [Badge]
    
    enum HabitFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case custom = "Custom"
    }
    
    struct Badge: Identifiable, Codable {
        var id = UUID()
        var name: String
        var icon: String
        var earnedAt: Date
    }
    
    var completionRate: Double {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 1
        return daysSinceCreation > 0 ? Double(totalCompletions) / Double(daysSinceCreation) : 0
    }
    
    var monthlyCompletionRate: Double {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentCompletions = completions.filter { $0 >= thirtyDaysAgo }
        return Double(recentCompletions.count) / 30.0
    }
    
    var weeklyCompletionRate: Double {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentCompletions = completions.filter { $0 >= sevenDaysAgo }
        return Double(recentCompletions.count) / 7.0
    }
    
    var averageCompletionsPerWeek: Double {
        let weeksSinceCreation = Calendar.current.dateComponents([.weekOfYear], from: createdAt, to: Date()).weekOfYear ?? 1
        return weeksSinceCreation > 0 ? Double(totalCompletions) / Double(weeksSinceCreation) : 0
    }
    
    var isCompletedToday: Bool {
        guard let lastCompletion = completions.last else { return false }
        return Calendar.current.isDateInToday(lastCompletion)
    }
}

class HabitManager: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var selectedHabit: Habit?
    
    private let habitsKey = "savedHabits"
    
    init() {
        loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habits.append(habit)
        }
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                habits[index] = habit
            }
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habits.removeAll { $0.id == habit.id }
        }
        saveHabits()
    }
    
    func completeHabit(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habits[index]
        
        // Don't allow multiple completions on the same day
        if updatedHabit.isCompletedToday {
            return
        }
        
        // Add completion
        updatedHabit.completions.append(Date())
        updatedHabit.totalCompletions += 1
        
        // Update streak
        updateStreak(for: &updatedHabit)
        
        // Check for new badges
        checkAndAwardBadges(for: &updatedHabit)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habits[index] = updatedHabit
        }
        
        saveHabits()
    }
    
    private func updateStreak(for habit: inout Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort completions by date
        let sortedCompletions = habit.completions.sorted(by: >)
        
        var streak = 1
        var currentDate = today
        
        for completion in sortedCompletions {
            let completionDay = calendar.startOfDay(for: completion)
            
            if calendar.isDate(completionDay, inSameDayAs: currentDate) {
                continue // Same day, continue counting
            } else if let daysBetween = calendar.dateComponents([.day], from: completionDay, to: currentDate).day,
                      daysBetween == 1 {
                streak += 1
                currentDate = completionDay
            } else {
                break // Streak broken
            }
        }
        
        habit.currentStreak = streak
        if streak > habit.longestStreak {
            habit.longestStreak = streak
        }
    }
    
    private func checkAndAwardBadges(for habit: inout Habit) {
        let existingBadgeNames = Set(habit.badges.map { $0.name })
        var newBadges: [Habit.Badge] = []
        
        // First completion badge
        if habit.totalCompletions == 1 && !existingBadgeNames.contains("First Step") {
            newBadges.append(Habit.Badge(name: "First Step", icon: "star.fill", earnedAt: Date()))
        }
        
        // Streak badges
        if habit.currentStreak == 7 && !existingBadgeNames.contains("Week Warrior") {
            newBadges.append(Habit.Badge(name: "Week Warrior", icon: "flame.fill", earnedAt: Date()))
        }
        
        if habit.currentStreak == 30 && !existingBadgeNames.contains("Month Master") {
            newBadges.append(Habit.Badge(name: "Month Master", icon: "crown.fill", earnedAt: Date()))
        }
        
        if habit.currentStreak == 100 && !existingBadgeNames.contains("Centurion") {
            newBadges.append(Habit.Badge(name: "Centurion", icon: "trophy.fill", earnedAt: Date()))
        }
        
        // Total completion badges
        if habit.totalCompletions == 50 && !existingBadgeNames.contains("Half Century") {
            newBadges.append(Habit.Badge(name: "Half Century", icon: "50.circle.fill", earnedAt: Date()))
        }
        
        habit.badges.append(contentsOf: newBadges)
    }
    
    func getWeeklyProgress(for habit: Habit) -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var progress: [Int] = []
        
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -6 + i, to: today) {
                let completionsOnDay = habit.completions.filter { calendar.isDate($0, inSameDayAs: day) }.count
                progress.append(completionsOnDay)
            }
        }
        
        return progress
    }
    
    func getMonthlyProgress(for habit: Habit) -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var progress: [Int] = []
        
        for i in 0..<30 {
            if let day = calendar.date(byAdding: .day, value: -29 + i, to: today) {
                let completionsOnDay = habit.completions.filter { calendar.isDate($0, inSameDayAs: day) }.count
                progress.append(completionsOnDay)
            }
        }
        
        return progress
    }
    
    func getHabitStatistics(for habit: Habit) -> HabitStatistics {
        let calendar = Calendar.current
        
        // Calculate best streak period
        var bestStreakStart: Date?
        var bestStreakEnd: Date?
        var currentStreakLength = 0
        var maxStreakLength = 0
        var tempStart: Date?
        
        let sortedCompletions = habit.completions.sorted()
        
        for (index, completion) in sortedCompletions.enumerated() {
            if index == 0 {
                currentStreakLength = 1
                tempStart = completion
            } else {
                let previousCompletion = sortedCompletions[index - 1]
                let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: previousCompletion), to: calendar.startOfDay(for: completion)).day ?? 0
                
                if daysBetween == 1 {
                    currentStreakLength += 1
                } else {
                    if currentStreakLength > maxStreakLength {
                        maxStreakLength = currentStreakLength
                        bestStreakStart = tempStart
                        bestStreakEnd = previousCompletion
                    }
                    currentStreakLength = 1
                    tempStart = completion
                }
            }
        }
        
        // Check final streak
        if currentStreakLength > maxStreakLength {
            maxStreakLength = currentStreakLength
            bestStreakStart = tempStart
            bestStreakEnd = sortedCompletions.last
        }
        
        // Calculate consistency score (0-100)
        let expectedCompletions = calendar.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 1
        let consistencyScore = min(100, Int((Double(habit.totalCompletions) / Double(expectedCompletions)) * 100))
        
        return HabitStatistics(
            totalDays: expectedCompletions,
            completionRate: habit.completionRate,
            monthlyRate: habit.monthlyCompletionRate,
            weeklyRate: habit.weeklyCompletionRate,
            currentStreak: habit.currentStreak,
            longestStreak: habit.longestStreak,
            bestStreakStart: bestStreakStart,
            bestStreakEnd: bestStreakEnd,
            consistencyScore: consistencyScore,
            averagePerWeek: habit.averageCompletionsPerWeek
        )
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
}

// Statistics model for detailed habit analytics
struct HabitStatistics {
    let totalDays: Int
    let completionRate: Double
    let monthlyRate: Double
    let weeklyRate: Double
    let currentStreak: Int
    let longestStreak: Int
    let bestStreakStart: Date?
    let bestStreakEnd: Date?
    let consistencyScore: Int
    let averagePerWeek: Double
    
    var completionRatePercent: String {
        String(format: "%.1f%%", completionRate * 100)
    }
    
    var monthlyRatePercent: String {
        String(format: "%.1f%%", monthlyRate * 100)
    }
    
    var weeklyRatePercent: String {
        String(format: "%.1f%%", weeklyRate * 100)
    }
}
