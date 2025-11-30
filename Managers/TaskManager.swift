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
    @Published var debouncedSearchText = ""
    @Published var filterPriority: Task.TaskPriority?
    @Published var showCompletedTasks = true
    
    private let tasksKey = "savedTasks"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTasks()
        requestNotificationPermission()
        setupDebouncedSearch()
    }
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            let matchesSearch = debouncedSearchText.isEmpty || 
                task.title.localizedCaseInsensitiveContains(debouncedSearchText) || 
                task.description.localizedCaseInsensitiveContains(debouncedSearchText) ||
                task.tags.contains(where: { $0.localizedCaseInsensitiveContains(debouncedSearchText) })
            let matchesPriority = filterPriority == nil || task.priority == filterPriority
            let matchesCompletion = showCompletedTasks || !task.isCompleted
            return matchesSearch && matchesPriority && matchesCompletion
        }.sorted { task1, task2 in
            // Completed tasks go to the bottom
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            
            // Sort by priority within same completion status
            if task1.priority != task2.priority {
                return priorityValue(task1.priority) > priorityValue(task2.priority)
            }
            
            // Then by due date (soonest first)
            if let date1 = task1.dueDate, let date2 = task2.dueDate {
                return date1 < date2
            } else if task1.dueDate != nil {
                return true
            } else if task2.dueDate != nil {
                return false
            }
            
            // Finally by creation date (newest first)
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
    
    private func setupDebouncedSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                self?.debouncedSearchText = value
            }
            .store(in: &cancellables)
    }
    
    private func priorityValue(_ priority: Task.TaskPriority) -> Int {
        switch priority {
        case .urgent: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
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
