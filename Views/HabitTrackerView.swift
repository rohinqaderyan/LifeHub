//
//  HabitTrackerView.swift
//  LifeHub
//
//  Habit tracking with progress rings, streaks, and gamification
//

import SwiftUI
import Charts

struct HabitTrackerView: View {
    @EnvironmentObject var habitManager: HabitManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                themeManager.currentTheme.gradient.opacity(0.05)
                    .ignoresSafeArea()
                
                if habitManager.habits.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Overall stats
                            overallStatsCard
                            
                            // Habits list
                            habitsGrid
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeManager.currentTheme.gradient)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
            }
        }
    }
    
    // MARK: - Overall Stats Card
    private var overallStatsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatBubble(
                    value: "\(habitManager.habits.count)",
                    label: "Total Habits",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatBubble(
                    value: "\(habitManager.habits.filter { $0.isCompletedToday }.count)",
                    label: "Today",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatBubble(
                    value: "\(habitManager.habits.map { $0.currentStreak }.max() ?? 0)",
                    label: "Best Streak",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .glassmorphic()
    }
    
    // MARK: - Habits Grid
    private var habitsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(habitManager.habits) { habit in
                HabitCard(habit: habit)
                    .onTapGesture {
                        selectedHabit = habit
                    }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 80))
                .foregroundStyle(themeManager.currentTheme.gradient)
            
            Text("No Habits Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start tracking your habits and build better routines!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddHabit = true }) {
                Label("Create Habit", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(themeManager.currentTheme.gradient)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Stat Bubble
struct StatBubble: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Habit Card
struct HabitCard: View {
    @EnvironmentObject var habitManager: HabitManager
    @EnvironmentObject var themeManager: ThemeManager
    let habit: Habit
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon and progress ring
            ZStack {
                // Progress ring
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: habit.isCompletedToday ? 1 : 0)
                    .stroke(
                        Color(hex: habit.color),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: habit.isCompletedToday)
                
                // Icon
                Image(systemName: habit.icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: habit.color))
            }
            
            // Habit name
            Text(habit.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            // Streak info
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(habit.currentStreak)")
                    .fontWeight(.bold)
                Text("day streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            // Complete button
            Button(action: { completeHabit() }) {
                Text(habit.isCompletedToday ? "Completed!" : "Mark Done")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        habit.isCompletedToday ?
                        Color.green :
                        Color(hex: habit.color)
                    )
                    .cornerRadius(8)
            }
            .disabled(habit.isCompletedToday)
        }
        .padding()
        .glassmorphic()
        .scaleEffect(isAnimating ? 1.0 : 0.95)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
    
    private func completeHabit() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            habitManager.completeHabit(habit)
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Habit Detail View
struct HabitDetailView: View {
    @EnvironmentObject var habitManager: HabitManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with icon
                    habitHeader
                    
                    // Stats grid
                    statsGrid
                    
                    // Weekly progress chart
                    weeklyProgressChart
                    
                    // Badges section
                    badgesSection
                    
                    // Complete button
                    completeButton
                }
                .padding()
            }
            .background(themeManager.currentTheme.gradient.opacity(0.05).ignoresSafeArea())
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive, action: deleteHabit) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    // MARK: - Habit Header
    private var habitHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: habit.color))
            }
            
            Text(habit.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            DetailStatCard(
                icon: "flame.fill",
                value: "\(habit.currentStreak)",
                label: "Current Streak",
                color: .orange
            )
            
            DetailStatCard(
                icon: "crown.fill",
                value: "\(habit.longestStreak)",
                label: "Best Streak",
                color: .yellow
            )
            
            DetailStatCard(
                icon: "checkmark.circle.fill",
                value: "\(habit.totalCompletions)",
                label: "Total Completions",
                color: .green
            )
            
            DetailStatCard(
                icon: "percent",
                value: "\(Int(habit.completionRate * 100))%",
                label: "Success Rate",
                color: .blue
            )
        }
    }
    
    // MARK: - Weekly Progress Chart
    private var weeklyProgressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Progress")
                .font(.headline)
            
            let weeklyData = habitManager.getWeeklyProgress(for: habit)
            
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
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .glassmorphic()
    }
    
    // MARK: - Badges Section
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
            
            if habit.badges.isEmpty {
                Text("Complete your habit to earn badges!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(habit.badges) { badge in
                        BadgeCard(badge: badge)
                    }
                }
            }
        }
        .padding()
        .glassmorphic()
    }
    
    // MARK: - Complete Button
    private var completeButton: some View {
        Button(action: completeHabit) {
            HStack {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                Text(habit.isCompletedToday ? "Completed Today!" : "Mark as Complete")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                habit.isCompletedToday ?
                Color.green :
                Color(hex: habit.color)
            )
            .cornerRadius(16)
        }
        .disabled(habit.isCompletedToday)
    }
    
    private func dayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -6 + index, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func completeHabit() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            habitManager.completeHabit(habit)
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func deleteHabit() {
        habitManager.deleteHabit(habit)
        dismiss()
    }
}

// MARK: - Detail Stat Card
struct DetailStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassmorphic()
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: Habit.Badge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.title)
                .foregroundColor(.yellow)
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(badge.earnedAt, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @EnvironmentObject var habitManager: HabitManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "00B4D8"
    @State private var goal = 1
    @State private var frequency: Habit.HabitFrequency = .daily
    
    let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "leaf.fill", "drop.fill", "book.fill", "dumbbell.fill", "bed.double.fill", "cup.and.saucer.fill"]
    let colors = ["00B4D8", "FF6B35", "2D6A4F", "7209B7", "00F5FF", "FF006E"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .gray)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Goal") {
                    Stepper("Daily goal: \(goal)", value: $goal, in: 1...10)
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(Habit.HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createHabit()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createHabit() {
        let habit = Habit(
            name: name,
            description: description,
            icon: selectedIcon,
            color: selectedColor,
            goal: goal,
            frequency: frequency,
            createdAt: Date(),
            completions: [],
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 0,
            badges: []
        )
        habitManager.addHabit(habit)
        dismiss()
    }
}

#Preview {
    HabitTrackerView()
        .environmentObject(HabitManager())
        .environmentObject(ThemeManager())
}
