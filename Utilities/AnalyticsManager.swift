//
//  AnalyticsManager.swift
//  LifeHub
//
//  Analytics and performance monitoring framework
//

import Foundation
import SwiftUI

// MARK: - Analytics Event

struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    let timestamp: Date
    let screen: String?
    
    init(name: String, parameters: [String: Any] = [:], screen: String? = nil) {
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
        self.screen = screen
    }
}

// MARK: - Analytics Manager

class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "analyticsEnabled")
        }
    }
    
    private var eventQueue: [AnalyticsEvent] = []
    private let maxQueueSize = 100
    
    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "analyticsEnabled")
    }
    
    // MARK: - Event Tracking
    
    func track(_ eventName: String, parameters: [String: Any] = [:], screen: String? = nil) {
        guard isEnabled else { return }
        
        let event = AnalyticsEvent(name: eventName, parameters: parameters, screen: screen)
        eventQueue.append(event)
        
        // Keep queue size manageable
        if eventQueue.count > maxQueueSize {
            eventQueue.removeFirst(eventQueue.count - maxQueueSize)
        }
        
        logEvent(event)
    }
    
    private func logEvent(_ event: AnalyticsEvent) {
        #if DEBUG
        var logMessage = "📊 Analytics: \(event.name)"
        if let screen = event.screen {
            logMessage += " | Screen: \(screen)"
        }
        if !event.parameters.isEmpty {
            logMessage += " | Params: \(event.parameters)"
        }
        print(logMessage)
        #endif
    }
    
    // MARK: - Screen Tracking
    
    func trackScreenView(_ screenName: String) {
        track("screen_view", parameters: ["screen_name": screenName], screen: screenName)
    }
    
    // MARK: - User Properties
    
    func setUserProperty(_ name: String, value: String) {
        guard isEnabled else { return }
        UserDefaults.standard.set(value, forKey: "userProperty_\(name)")
        
        #if DEBUG
        print("👤 User Property: \(name) = \(value)")
        #endif
    }
    
    // MARK: - Common Events
    
    func trackTaskCreated(priority: String) {
        track("task_created", parameters: ["priority": priority])
    }
    
    func trackTaskCompleted(priority: String, timeToComplete: TimeInterval) {
        track("task_completed", parameters: [
            "priority": priority,
            "time_to_complete": timeToComplete
        ])
    }
    
    func trackHabitCompleted(habitName: String, streak: Int) {
        track("habit_completed", parameters: [
            "habit_name": habitName,
            "streak": streak
        ])
    }
    
    func trackThemeChanged(themeName: String) {
        track("theme_changed", parameters: ["theme_name": themeName])
    }
    
    func trackMediaPlayed(trackName: String, source: String) {
        track("media_played", parameters: [
            "track_name": trackName,
            "source": source
        ])
    }
    
    func trackFeatureUsed(feature: String) {
        track("feature_used", parameters: ["feature": feature])
    }
    
    func trackError(error: String, context: String) {
        track("error_occurred", parameters: [
            "error": error,
            "context": context
        ])
    }
    
    // MARK: - Session Management
    
    func startSession() {
        track("session_start")
        setUserProperty("last_session_date", value: Date().ISO8601Format())
    }
    
    func endSession(duration: TimeInterval) {
        track("session_end", parameters: ["duration": duration])
    }
    
    // MARK: - Export Analytics
    
    func exportEvents() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let eventDicts = eventQueue.map { event -> [String: Any] in
            var dict: [String: Any] = [
                "name": event.name,
                "timestamp": ISO8601DateFormatter().string(from: event.timestamp)
            ]
            
            if let screen = event.screen {
                dict["screen"] = screen
            }
            
            if !event.parameters.isEmpty {
                dict["parameters"] = event.parameters
            }
            
            return dict
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: eventDicts, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "[]"
    }
    
    func clearEvents() {
        eventQueue.removeAll()
    }
}

// MARK: - Performance Monitor

class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()
    
    @Published var metrics: [PerformanceMetric] = []
    
    private var timers: [String: Date] = [:]
    
    private init() {}
    
    // MARK: - Timing
    
    func startTimer(_ name: String) {
        timers[name] = Date()
    }
    
    func stopTimer(_ name: String) -> TimeInterval? {
        guard let startTime = timers[name] else { return nil }
        let duration = Date().timeIntervalSince(startTime)
        timers.removeValue(forKey: name)
        
        let metric = PerformanceMetric(
            name: name,
            duration: duration,
            timestamp: Date()
        )
        metrics.append(metric)
        
        #if DEBUG
        print("⏱️ Performance: \(name) took \(String(format: "%.3f", duration))s")
        #endif
        
        return duration
    }
    
    // MARK: - Memory Usage
    
    func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return result == KERN_SUCCESS ? info.resident_size : 0
    }
    
    func getFormattedMemoryUsage() -> String {
        let bytes = Double(getCurrentMemoryUsage())
        let mb = bytes / 1024 / 1024
        return String(format: "%.2f MB", mb)
    }
    
    // MARK: - Report
    
    func generatePerformanceReport() -> PerformanceReport {
        let totalDuration = metrics.reduce(0.0) { $0 + $1.duration }
        let averageDuration = metrics.isEmpty ? 0.0 : totalDuration / Double(metrics.count)
        
        let slowestMetric = metrics.max { $0.duration < $1.duration }
        let fastestMetric = metrics.min { $0.duration < $1.duration }
        
        return PerformanceReport(
            totalMetrics: metrics.count,
            totalDuration: totalDuration,
            averageDuration: averageDuration,
            memoryUsage: getCurrentMemoryUsage(),
            slowestOperation: slowestMetric,
            fastestOperation: fastestMetric
        )
    }
    
    func clearMetrics() {
        metrics.removeAll()
    }
}

// MARK: - Performance Metric

struct PerformanceMetric: Identifiable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
    let timestamp: Date
}

// MARK: - Performance Report

struct PerformanceReport {
    let totalMetrics: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let memoryUsage: UInt64
    let slowestOperation: PerformanceMetric?
    let fastestOperation: PerformanceMetric?
    
    var formattedMemoryUsage: String {
        let mb = Double(memoryUsage) / 1024 / 1024
        return String(format: "%.2f MB", mb)
    }
    
    var description: String {
        var report = """
        Performance Report
        ==================
        Total Operations: \(totalMetrics)
        Total Duration: \(String(format: "%.3f", totalDuration))s
        Average Duration: \(String(format: "%.3f", averageDuration))s
        Memory Usage: \(formattedMemoryUsage)
        """
        
        if let slowest = slowestOperation {
            report += "\nSlowest: \(slowest.name) (\(String(format: "%.3f", slowest.duration))s)"
        }
        
        if let fastest = fastestOperation {
            report += "\nFastest: \(fastest.name) (\(String(format: "%.3f", fastest.duration))s)"
        }
        
        return report
    }
}

// MARK: - View Modifier for Analytics

struct AnalyticsTracker: ViewModifier {
    let screenName: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                AnalyticsManager.shared.trackScreenView(screenName)
            }
    }
}

extension View {
    func trackScreen(_ name: String) -> some View {
        self.modifier(AnalyticsTracker(screenName: name))
    }
}

// MARK: - View Modifier for Performance

struct PerformanceTracker: ViewModifier {
    let operationName: String
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !hasAppeared {
                    PerformanceMonitor.shared.startTimer(operationName)
                    hasAppeared = true
                }
            }
            .onDisappear {
                PerformanceMonitor.shared.stopTimer(operationName)
            }
    }
}

extension View {
    func trackPerformance(_ name: String) -> some View {
        self.modifier(PerformanceTracker(operationName: name))
    }
}

// MARK: - Crash Reporter

class CrashReporter {
    static let shared = CrashReporter()
    
    private init() {
        setupExceptionHandler()
    }
    
    private func setupExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            let report = """
            Crash Report
            ============
            Exception: \(exception.name.rawValue)
            Reason: \(exception.reason ?? "Unknown")
            Call Stack: \(exception.callStackSymbols.joined(separator: "\n"))
            """
            
            #if DEBUG
            print("💥 CRASH: \(report)")
            #endif
            
            // Save crash report
            UserDefaults.standard.set(report, forKey: "lastCrashReport")
            AnalyticsManager.shared.trackError(error: exception.name.rawValue, context: "app_crash")
        }
    }
    
    func getLastCrashReport() -> String? {
        return UserDefaults.standard.string(forKey: "lastCrashReport")
    }
    
    func clearLastCrashReport() {
        UserDefaults.standard.removeObject(forKey: "lastCrashReport")
    }
}

// MARK: - Network Monitor

class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi
    
    enum ConnectionType {
        case wifi
        case cellular
        case none
    }
    
    // In a real app, you would use NWPathMonitor from Network framework
    // This is a simplified version for demonstration
}

// MARK: - App Info Helper

struct AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "com.lifehub.app"
    }
    
    static var deviceModel: String {
        UIDevice.current.model
    }
    
    static var osVersion: String {
        UIDevice.current.systemVersion
    }
    
    static var formattedInfo: String {
        """
        App Version: \(version) (\(build))
        Bundle ID: \(bundleId)
        Device: \(deviceModel)
        iOS: \(osVersion)
        """
    }
}
