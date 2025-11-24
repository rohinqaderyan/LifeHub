//
//  HomeDashboardView.swift
//  LifeHub
//
//  Dynamic dashboard with weather, calendar, and news widgets
//

import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var habitManager: HabitManager
    @State private var greeting = ""
    @State private var showAddWidget = false
    @State private var widgets: [DashboardWidget] = [.weather, .tasks, .habits, .quote]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting header
                    greetingHeader
                    
                    // Quick stats
                    quickStatsRow
                    
                    // Widgets
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(widgets, id: \.self) { widget in
                            widgetView(for: widget)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(
                themeManager.currentTheme.gradient.opacity(0.1)
                    .ignoresSafeArea()
            )
            .navigationTitle("LifeHub")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddWidget.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeManager.currentTheme.gradient)
                    }
                }
            }
        }
        .onAppear {
            updateGreeting()
        }
    }
    
    // MARK: - Greeting Header
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(themeManager.currentTheme.gradient)
            
            Text("Ready to crush your goals today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - Quick Stats
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                icon: "checkmark.circle.fill",
                value: "\(taskManager.tasks.filter { !$0.isCompleted }.count)",
                label: "Tasks",
                color: .blue
            )
            
            QuickStatCard(
                icon: "flame.fill",
                value: "\(habitManager.habits.filter { $0.currentStreak > 0 }.count)",
                label: "Streaks",
                color: .orange
            )
            
            QuickStatCard(
                icon: "star.fill",
                value: "\(habitManager.habits.flatMap { $0.badges }.count)",
                label: "Badges",
                color: .yellow
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Widget Views
    @ViewBuilder
    private func widgetView(for widget: DashboardWidget) -> some View {
        switch widget {
        case .weather:
            WeatherWidget()
        case .tasks:
            TasksWidget()
        case .habits:
            HabitsWidget()
        case .quote:
            QuoteWidget()
        case .calendar:
            CalendarWidget()
        case .news:
            NewsWidget()
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            greeting = "Good Morning! ☀️"
        case 12..<17:
            greeting = "Good Afternoon! 🌤️"
        case 17..<21:
            greeting = "Good Evening! 🌅"
        default:
            greeting = "Good Night! 🌙"
        }
    }
}

// MARK: - Dashboard Widget Types
enum DashboardWidget: String, CaseIterable {
    case weather, tasks, habits, quote, calendar, news
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassmorphic()
    }
}

// MARK: - Weather Widget
struct WeatherWidget: View {
    @State private var temperature = 72
    @State private var condition = "Sunny"
    @State private var location = "San Francisco"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: weatherIcon)
                    .font(.title)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("\(temperature)°")
                    .font(.system(size: 32, weight: .bold))
            }
            
            Text(condition)
                .font(.headline)
            
            Text(location)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassmorphic()
        .frame(height: 150)
    }
    
    private var weatherIcon: String {
        switch condition {
        case "Sunny": return "sun.max.fill"
        case "Cloudy": return "cloud.fill"
        case "Rainy": return "cloud.rain.fill"
        default: return "sun.max.fill"
        }
    }
}

// MARK: - Tasks Widget
struct TasksWidget: View {
    @EnvironmentObject var taskManager: TaskManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Tasks")
                    .font(.headline)
                
                Spacer()
            }
            
            let pendingTasks = taskManager.tasks.filter { !$0.isCompleted }
            
            if pendingTasks.isEmpty {
                Text("All done! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(pendingTasks.prefix(3)) { task in
                        HStack {
                            Circle()
                                .fill(task.priority.color)
                                .frame(width: 8, height: 8)
                            
                            Text(task.title)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            Spacer()
            
            Text("\(pendingTasks.count) pending")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassmorphic()
        .frame(height: 150)
    }
}

// MARK: - Habits Widget
struct HabitsWidget: View {
    @EnvironmentObject var habitManager: HabitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Habits")
                    .font(.headline)
                
                Spacer()
            }
            
            if habitManager.habits.isEmpty {
                Text("Start a habit!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                let maxStreak = habitManager.habits.map { $0.currentStreak }.max() ?? 0
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(maxStreak) Day Streak! 🔥")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("\(habitManager.habits.filter { $0.isCompletedToday }.count)/\(habitManager.habits.count) completed today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassmorphic()
        .frame(height: 150)
    }
}

// MARK: - Quote Widget
struct QuoteWidget: View {
    @State private var currentQuote = DailyQuote.random()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "quote.bubble.fill")
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(currentQuote.text)
                .font(.subheadline)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Text("— \(currentQuote.author)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassmorphic()
        .frame(height: 180)
    }
}

// MARK: - Calendar Widget
struct CalendarWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Today")
                    .font(.headline)
                
                Spacer()
            }
            
            Text(Date(), style: .date)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassmorphic()
        .frame(height: 150)
    }
}

// MARK: - News Widget
struct NewsWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "newspaper.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("News")
                    .font(.headline)
                
                Spacer()
            }
            
            Text("Stay updated with the latest")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassmorphic()
        .frame(height: 150)
    }
}

// MARK: - Daily Quote Model
struct DailyQuote {
    let text: String
    let author: String
    
    static func random() -> DailyQuote {
        let quotes = [
            DailyQuote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
            DailyQuote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
            DailyQuote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
            DailyQuote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
            DailyQuote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius")
        ]
        return quotes.randomElement() ?? quotes[0]
    }
}

#Preview {
    HomeDashboardView()
        .environmentObject(ThemeManager())
        .environmentObject(TaskManager())
        .environmentObject(HabitManager())
}
