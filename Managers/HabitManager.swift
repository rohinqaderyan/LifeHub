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
