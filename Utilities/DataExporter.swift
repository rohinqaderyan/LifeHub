//
//  DataExporter.swift
//  LifeHub
//
//  Handles data export and import for backup/restore functionality
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportData: Codable {
    var tasks: [Task]
    var habits: [Habit]
    var exportDate: Date
    var appVersion: String
}

class DataExporter {
    
    // MARK: - Export Functions
    
    static func exportToJSON(tasks: [Task], habits: [Habit]) -> Result<Data, ExportError> {
        let exportData = ExportData(
            tasks: tasks,
            habits: habits,
            exportDate: Date(),
            appVersion: "1.0.0"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let jsonData = try encoder.encode(exportData)
            return .success(jsonData)
        } catch {
            return .failure(.encodingFailed(error))
        }
    }
    
    static func exportTasksToJSON(_ tasks: [Task]) -> Result<Data, ExportError> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let jsonData = try encoder.encode(tasks)
            return .success(jsonData)
        } catch {
            return .failure(.encodingFailed(error))
        }
    }
    
    static func exportHabitsToJSON(_ habits: [Habit]) -> Result<Data, ExportError> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let jsonData = try encoder.encode(habits)
            return .success(jsonData)
        } catch {
            return .failure(.encodingFailed(error))
        }
    }
    
    // MARK: - Import Functions
    
    static func importFromJSON(_ data: Data) -> Result<ExportData, ExportError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let exportData = try decoder.decode(ExportData.self, from: data)
            return .success(exportData)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    static func importTasksFromJSON(_ data: Data) -> Result<[Task], ExportError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let tasks = try decoder.decode([Task].self, from: data)
            return .success(tasks)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    static func importHabitsFromJSON(_ data: Data) -> Result<[Habit], ExportError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let habits = try decoder.decode([Habit].self, from: data)
            return .success(habits)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    // MARK: - File Operations
    
    static func saveToFile(_ data: Data, filename: String) -> Result<URL, ExportError> {
        let fileManager = FileManager.default
        
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.fileSystemError("Could not access document directory"))
        }
        
        let fileURL = documentDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return .success(fileURL)
        } catch {
            return .failure(.fileSystemError("Could not write to file: \(error.localizedDescription)"))
        }
    }
    
    static func loadFromFile(_ url: URL) -> Result<Data, ExportError> {
        do {
            let data = try Data(contentsOf: url)
            return .success(data)
        } catch {
            return .failure(.fileSystemError("Could not read file: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - Validation
    
    static func validateImportData(_ data: ExportData) -> [String] {
        var warnings: [String] = []
        
        // Check for duplicate IDs
        let taskIDs = Set(data.tasks.map { $0.id })
        if taskIDs.count != data.tasks.count {
            warnings.append("Some tasks have duplicate IDs")
        }
        
        let habitIDs = Set(data.habits.map { $0.id })
        if habitIDs.count != data.habits.count {
            warnings.append("Some habits have duplicate IDs")
        }
        
        // Check for invalid dates
        let now = Date()
        let distantFuture = Calendar.current.date(byAdding: .year, value: 10, to: now) ?? now
        
        for task in data.tasks {
            if task.createdAt > now {
                warnings.append("Task '\(task.title)' has a creation date in the future")
            }
            if let dueDate = task.dueDate, dueDate > distantFuture {
                warnings.append("Task '\(task.title)' has an unusually distant due date")
            }
        }
        
        for habit in data.habits {
            if habit.createdAt > now {
                warnings.append("Habit '\(habit.name)' has a creation date in the future")
            }
        }
        
        return warnings
    }
    
    // MARK: - Statistics
    
    static func generateExportSummary(tasks: [Task], habits: [Habit]) -> String {
        let completedTasks = tasks.filter { $0.isCompleted }.count
        let pendingTasks = tasks.count - completedTasks
        let activeHabits = habits.count
        let totalBadges = habits.reduce(0) { $0 + $1.badges.count }
        
        return """
        LifeHub Data Export Summary
        ===========================
        
        Export Date: \(DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .short))
        
        Tasks:
        - Total: \(tasks.count)
        - Completed: \(completedTasks)
        - Pending: \(pendingTasks)
        
        Habits:
        - Total: \(activeHabits)
        - Total Badges Earned: \(totalBadges)
        
        This file contains all your LifeHub data and can be used to restore your information.
        """
    }
}

// MARK: - Error Handling

enum ExportError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileSystemError(String)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to export data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to import data: \(error.localizedDescription)"
        case .fileSystemError(let message):
            return "File system error: \(message)"
        case .invalidData:
            return "The import data is invalid or corrupted"
        }
    }
}

// MARK: - SwiftUI Document Types

struct LifeHubDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var exportData: ExportData
    
    init(tasks: [Task], habits: [Habit]) {
        self.exportData = ExportData(
            tasks: tasks,
            habits: habits,
            exportDate: Date(),
            appVersion: "1.0.0"
        )
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        exportData = try decoder.decode(ExportData.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(exportData)
        return FileWrapper(regularFileWithContents: data)
    }
}
