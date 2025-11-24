//
//  TaskManager.swift
//  LifeHub
//
//  Manages tasks with Core Data persistence
//

import SwiftUI
import Combine
import UserNotifications

// Task model
struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var priority: TaskPriority
    var isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?
    var tags: [String]
    
    enum TaskPriority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .blue
            case .high: return .orange
            case .urgent: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "arrow.down.circle.fill"
            case .medium: return "equal.circle.fill"
            case .high: return "arrow.up.circle.fill"
            case .urgent: return "exclamationmark.triangle.fill"
            }
        }
    }
}

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var searchText = ""
    @Published var filterPriority: Task.TaskPriority?
    @Published var showCompletedTasks = true
    
    private let tasksKey = "savedTasks"
    
    init() {
        loadTasks()
        requestNotificationPermission()
    }
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            let matchesSearch = searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText) || task.description.localizedCaseInsensitiveContains(searchText)
            let matchesPriority = filterPriority == nil || task.priority == filterPriority
            let matchesCompletion = showCompletedTasks || !task.isCompleted
            return matchesSearch && matchesPriority && matchesCompletion
        }.sorted { task1, task2 in
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            return task1.createdAt > task2.createdAt
        }
    }
    
    func addTask(_ task: Task) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            tasks.append(task)
        }
        saveTasks()
        scheduleNotification(for: task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tasks[index] = task
            }
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            tasks.removeAll { $0.id == task.id }
        }
        saveTasks()
        cancelNotification(for: task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tasks[index].isCompleted.toggle()
                tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
            }
            saveTasks()
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    private func scheduleNotification(for task: Task) {
        guard let dueDate = task.dueDate, dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(task.title)"
        content.body = task.description
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
