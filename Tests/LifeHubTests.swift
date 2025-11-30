//
//  LifeHubTests.swift
//  LifeHub Tests
//
//  Unit tests for LifeHub managers and core functionality
//

import XCTest
@testable import LifeHub

final class TaskManagerTests: XCTestCase {
    var taskManager: TaskManager!
    
    override func setUp() {
        super.setUp()
        taskManager = TaskManager()
        taskManager.tasks = [] // Clear any saved tasks
    }
    
    override func tearDown() {
        taskManager = nil
        super.tearDown()
    }
    
    func testAddTask() {
        let task = Task(
            title: "Test Task",
            description: "Test Description",
            priority: .medium,
            isCompleted: false,
            dueDate: Date(),
            createdAt: Date(),
            completedAt: nil,
            tags: ["test"]
        )
        
        taskManager.addTask(task)
        
        XCTAssertEqual(taskManager.tasks.count, 1)
        XCTAssertEqual(taskManager.tasks.first?.title, "Test Task")
    }
    
    func testDeleteTask() {
        let task = Task(
            title: "Test Task",
            description: "Test Description",
            priority: .medium,
            isCompleted: false,
            dueDate: Date(),
            createdAt: Date(),
            completedAt: nil,
            tags: ["test"]
        )
        
        taskManager.addTask(task)
        XCTAssertEqual(taskManager.tasks.count, 1)
        
        taskManager.deleteTask(task)
        XCTAssertEqual(taskManager.tasks.count, 0)
    }
    
    func testToggleTaskCompletion() {
        let task = Task(
            title: "Test Task",
            description: "Test Description",
            priority: .medium,
            isCompleted: false,
            dueDate: Date(),
            createdAt: Date(),
            completedAt: nil,
            tags: ["test"]
        )
        
        taskManager.addTask(task)
        XCTAssertFalse(taskManager.tasks.first!.isCompleted)
        
        taskManager.toggleTaskCompletion(task)
        XCTAssertTrue(taskManager.tasks.first!.isCompleted)
        XCTAssertNotNil(taskManager.tasks.first!.completedAt)
    }
    
    func testFilteredTasksByPriority() {
        let urgentTask = Task(title: "Urgent", description: "", priority: .urgent, isCompleted: false, dueDate: nil, createdAt: Date(), completedAt: nil, tags: [])
        let lowTask = Task(title: "Low", description: "", priority: .low, isCompleted: false, dueDate: nil, createdAt: Date(), completedAt: nil, tags: [])
        
        taskManager.addTask(urgentTask)
        taskManager.addTask(lowTask)
        
        taskManager.filterPriority = .urgent
        XCTAssertEqual(taskManager.filteredTasks.count, 1)
        XCTAssertEqual(taskManager.filteredTasks.first?.title, "Urgent")
    }
    
    func testPrioritySorting() {
        let urgentTask = Task(title: "Urgent", description: "", priority: .urgent, isCompleted: false, dueDate: nil, createdAt: Date(), completedAt: nil, tags: [])
        let lowTask = Task(title: "Low", description: "", priority: .low, isCompleted: false, dueDate: nil, createdAt: Date(), completedAt: nil, tags: [])
        let highTask = Task(title: "High", description: "", priority: .high, isCompleted: false, dueDate: nil, createdAt: Date(), completedAt: nil, tags: [])
        
        taskManager.addTask(lowTask)
        taskManager.addTask(urgentTask)
        taskManager.addTask(highTask)
        
        let filteredTasks = taskManager.filteredTasks
        XCTAssertEqual(filteredTasks[0].priority, .urgent)
        XCTAssertEqual(filteredTasks[1].priority, .high)
        XCTAssertEqual(filteredTasks[2].priority, .low)
    }
}

final class HabitManagerTests: XCTestCase {
    var habitManager: HabitManager!
    
    override func setUp() {
        super.setUp()
        habitManager = HabitManager()
        habitManager.habits = []
    }
    
    override func tearDown() {
        habitManager = nil
        super.tearDown()
    }
    
    func testAddHabit() {
        let habit = Habit(
            name: "Test Habit",
            description: "Test Description",
            icon: "star.fill",
            color: "0077B6",
            goal: 1,
            frequency: .daily,
            createdAt: Date(),
            completions: [],
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 0,
            badges: []
        )
        
        habitManager.addHabit(habit)
        
        XCTAssertEqual(habitManager.habits.count, 1)
        XCTAssertEqual(habitManager.habits.first?.name, "Test Habit")
    }
    
    func testCompleteHabit() {
        var habit = Habit(
            name: "Test Habit",
            description: "Test Description",
            icon: "star.fill",
            color: "0077B6",
            goal: 1,
            frequency: .daily,
            createdAt: Date(),
            completions: [],
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 0,
            badges: []
        )
        
        habitManager.addHabit(habit)
        habitManager.completeHabit(habit)
        
        habit = habitManager.habits.first!
        XCTAssertEqual(habit.totalCompletions, 1)
        XCTAssertEqual(habit.currentStreak, 1)
        XCTAssertTrue(habit.isCompletedToday)
    }
    
    func testStreakTracking() {
        var habit = Habit(
            name: "Test Habit",
            description: "Test Description",
            icon: "star.fill",
            color: "0077B6",
            goal: 1,
            frequency: .daily,
            createdAt: Date().addingTimeInterval(-86400 * 3), // 3 days ago
            completions: [],
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 0,
            badges: []
        )
        
        habitManager.addHabit(habit)
        
        // Complete for 3 consecutive days
        habit.completions = [
            Date().addingTimeInterval(-86400 * 2), // 2 days ago
            Date().addingTimeInterval(-86400),     // yesterday
            Date()                                  // today
        ]
        
        habitManager.updateHabit(habit)
        habitManager.completeHabit(habit)
        
        let updatedHabit = habitManager.habits.first!
        XCTAssertGreaterThanOrEqual(updatedHabit.currentStreak, 1)
    }
    
    func testBadgeAward() {
        var habit = Habit(
            name: "Test Habit",
            description: "Test Description",
            icon: "star.fill",
            color: "0077B6",
            goal: 1,
            frequency: .daily,
            createdAt: Date(),
            completions: [],
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 0,
            badges: []
        )
        
        habitManager.addHabit(habit)
        habitManager.completeHabit(habit)
        
        habit = habitManager.habits.first!
        XCTAssertFalse(habit.badges.isEmpty, "Should award 'First Step' badge")
        XCTAssertEqual(habit.badges.first?.name, "First Step")
    }
    
    func testCompletionRate() {
        let habit = Habit(
            name: "Test Habit",
            description: "Test Description",
            icon: "star.fill",
            color: "0077B6",
            goal: 1,
            frequency: .daily,
            createdAt: Date().addingTimeInterval(-86400 * 10), // 10 days ago
            completions: [Date(), Date().addingTimeInterval(-86400)],
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 2,
            badges: []
        )
        
        XCTAssertGreaterThan(habit.completionRate, 0)
        XCTAssertLessThanOrEqual(habit.completionRate, 1.0)
    }
    
    func testMonthlyCompletionRate() {
        let habit = Habit(
            name: "Test Habit",
            description: "Test Description",
            icon: "star.fill",
            color: "0077B6",
            goal: 1,
            frequency: .daily,
            createdAt: Date().addingTimeInterval(-86400 * 40),
            completions: Array(0..<15).map { Date().addingTimeInterval(-86400 * Double($0)) },
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 15,
            badges: []
        )
        
        XCTAssertGreaterThan(habit.monthlyCompletionRate, 0)
        XCTAssertLessThanOrEqual(habit.monthlyCompletionRate, 1.0)
    }
}

final class ThemeManagerTests: XCTestCase {
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        themeManager = ThemeManager()
    }
    
    override func tearDown() {
        themeManager = nil
        super.tearDown()
    }
    
    func testDefaultTheme() {
        XCTAssertNotNil(themeManager.currentTheme)
        XCTAssertEqual(themeManager.themes.count, 6)
    }
    
    func testSelectTheme() {
        let newTheme = themeManager.themes[1]
        themeManager.selectTheme(newTheme)
        
        XCTAssertEqual(themeManager.currentTheme.id, newTheme.id)
    }
    
    func testDarkModeToggle() {
        let initialMode = themeManager.isDarkMode
        themeManager.isDarkMode.toggle()
        
        XCTAssertNotEqual(themeManager.isDarkMode, initialMode)
        XCTAssertEqual(themeManager.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    func testCreateCustomTheme() {
        let initialCount = themeManager.customThemes.count
        
        themeManager.createCustomTheme(
            name: "Test Theme",
            accentColor: .blue,
            gradientStart: .purple,
            gradientEnd: .pink
        )
        
        XCTAssertEqual(themeManager.customThemes.count, initialCount + 1)
        XCTAssertEqual(themeManager.customThemes.last?.name, "Test Theme")
        XCTAssertEqual(themeManager.currentTheme.name, "Test Theme")
    }
    
    func testDeleteCustomTheme() {
        themeManager.createCustomTheme(
            name: "Test Theme",
            accentColor: .blue,
            gradientStart: .purple,
            gradientEnd: .pink
        )
        
        let customTheme = themeManager.customThemes.last!
        let count = themeManager.customThemes.count
        
        themeManager.deleteCustomTheme(customTheme)
        
        XCTAssertEqual(themeManager.customThemes.count, count - 1)
    }
    
    func testHexColorConversion() {
        let color = Color(hex: "FF6B35")
        XCTAssertNotNil(color)
        
        let hexString = color.toHex()
        XCTAssertNotNil(hexString)
    }
}

final class DataExporterTests: XCTestCase {
    
    func testExportTasks() {
        let tasks = [
            Task(title: "Task 1", description: "Description", priority: .medium, isCompleted: false, dueDate: Date(), createdAt: Date(), completedAt: nil, tags: ["test"]),
            Task(title: "Task 2", description: "Description", priority: .high, isCompleted: true, dueDate: Date(), createdAt: Date(), completedAt: Date(), tags: ["test"])
        ]
        
        let result = DataExporter.exportTasksToJSON(tasks)
        
        switch result {
        case .success(let data):
            XCTAssertGreaterThan(data.count, 0)
        case .failure(let error):
            XCTFail("Export failed: \(error.localizedDescription)")
        }
    }
    
    func testImportTasks() {
        let tasks = [
            Task(title: "Task 1", description: "Description", priority: .medium, isCompleted: false, dueDate: Date(), createdAt: Date(), completedAt: nil, tags: ["test"])
        ]
        
        let exportResult = DataExporter.exportTasksToJSON(tasks)
        
        switch exportResult {
        case .success(let data):
            let importResult = DataExporter.importTasksFromJSON(data)
            
            switch importResult {
            case .success(let importedTasks):
                XCTAssertEqual(importedTasks.count, tasks.count)
                XCTAssertEqual(importedTasks.first?.title, tasks.first?.title)
            case .failure(let error):
                XCTFail("Import failed: \(error.localizedDescription)")
            }
        case .failure(let error):
            XCTFail("Export failed: \(error.localizedDescription)")
        }
    }
    
    func testExportFullData() {
        let tasks = [Task(title: "Task", description: "", priority: .medium, isCompleted: false, dueDate: nil, createdAt: Date(), completedAt: nil, tags: [])]
        let habits = [Habit(name: "Habit", description: "", icon: "star", color: "blue", goal: 1, frequency: .daily, createdAt: Date(), completions: [], currentStreak: 0, longestStreak: 0, totalCompletions: 0, badges: [])]
        
        let result = DataExporter.exportToJSON(tasks: tasks, habits: habits)
        
        switch result {
        case .success(let data):
            XCTAssertGreaterThan(data.count, 0)
            
            let importResult = DataExporter.importFromJSON(data)
            switch importResult {
            case .success(let exportData):
                XCTAssertEqual(exportData.tasks.count, 1)
                XCTAssertEqual(exportData.habits.count, 1)
            case .failure(let error):
                XCTFail("Import failed: \(error.localizedDescription)")
            }
        case .failure(let error):
            XCTFail("Export failed: \(error.localizedDescription)")
        }
    }
    
    func testValidateImportData() {
        let tasks = [Task(title: "Task", description: "", priority: .medium, isCompleted: false, dueDate: nil, createdAt: Date(), completedAt: nil, tags: [])]
        let habits = [Habit(name: "Habit", description: "", icon: "star", color: "blue", goal: 1, frequency: .daily, createdAt: Date(), completions: [], currentStreak: 0, longestStreak: 0, totalCompletions: 0, badges: [])]
        
        let exportData = ExportData(tasks: tasks, habits: habits, exportDate: Date(), appVersion: "1.0.0")
        let warnings = DataExporter.validateImportData(exportData)
        
        XCTAssertTrue(warnings.isEmpty, "Valid data should have no warnings")
    }
}
