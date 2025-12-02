//
//  UserDefaultsExtensions.swift
//  LifeHub
//
//  Property wrappers and utilities for cleaner UserDefaults persistence
//

import Foundation
import SwiftUI

// MARK: - Property Wrapper for UserDefaults

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults
    
    init(key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
    
    var wrappedValue: T {
        get {
            storage.object(forKey: key) as? T ?? defaultValue
        }
        set {
            storage.set(newValue, forKey: key)
        }
    }
}

// MARK: - Property Wrapper for Codable UserDefaults

@propertyWrapper
struct CodableUserDefault<T: Codable> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults
    
    init(key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
    
    var wrappedValue: T {
        get {
            guard let data = storage.data(forKey: key) else { return defaultValue }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            storage.set(data, forKey: key)
        }
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    
    /// Save Codable object to UserDefaults
    func set<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            set(encoded, forKey: key)
        }
    }
    
    /// Retrieve Codable object from UserDefaults
    func object<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
    
    /// Check if key exists
    func hasValue(forKey key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    /// Remove multiple keys at once
    func removeValues(forKeys keys: [String]) {
        keys.forEach { removeObject(forKey: $0) }
    }
    
    /// Clear all user defaults (use with caution)
    func clearAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            removePersistentDomain(forName: bundleID)
        }
    }
    
    /// Get all stored keys
    var allKeys: [String] {
        return Array(dictionaryRepresentation().keys)
    }
    
    /// Get storage size in bytes
    var storageSize: Int {
        let dict = dictionaryRepresentation()
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        return data?.count ?? 0
    }
    
    /// Get formatted storage size
    var formattedStorageSize: String {
        let bytes = Double(storageSize)
        let kb = bytes / 1024
        let mb = kb / 1024
        
        if mb >= 1 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1 {
            return String(format: "%.2f KB", kb)
        } else {
            return "\(Int(bytes)) bytes"
        }
    }
}

// MARK: - UserDefaults Keys Manager

struct UserDefaultsKeys {
    // Theme
    static let selectedTheme = "selectedTheme"
    static let isDarkMode = "isDarkMode"
    static let customThemes = "customThemes"
    
    // Tasks
    static let savedTasks = "savedTasks"
    static let taskFilters = "taskFilters"
    static let taskSortOrder = "taskSortOrder"
    
    // Habits
    static let savedHabits = "savedHabits"
    static let habitReminders = "habitReminders"
    static let habitNotificationsEnabled = "habitNotificationsEnabled"
    
    // Settings
    static let notificationsEnabled = "notificationsEnabled"
    static let soundEnabled = "soundEnabled"
    static let hapticsEnabled = "hapticsEnabled"
    static let analyticsEnabled = "analyticsEnabled"
    
    // Onboarding
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let appVersion = "appVersion"
    static let firstLaunchDate = "firstLaunchDate"
    
    // Media
    static let lastPlayedTrack = "lastPlayedTrack"
    static let repeatMode = "repeatMode"
    static let shuffleEnabled = "shuffleEnabled"
    
    /// Get all keys as array
    static var allKeys: [String] {
        return [
            selectedTheme, isDarkMode, customThemes,
            savedTasks, taskFilters, taskSortOrder,
            savedHabits, habitReminders, habitNotificationsEnabled,
            notificationsEnabled, soundEnabled, hapticsEnabled, analyticsEnabled,
            hasCompletedOnboarding, appVersion, firstLaunchDate,
            lastPlayedTrack, repeatMode, shuffleEnabled
        ]
    }
}

// MARK: - AppStorage Property Wrapper Alternative

/// Provides observable UserDefaults with SwiftUI binding support
class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled) }
    }
    
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: UserDefaultsKeys.soundEnabled) }
    }
    
    @Published var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: UserDefaultsKeys.hapticsEnabled) }
    }
    
    @Published var analyticsEnabled: Bool {
        didSet { UserDefaults.standard.set(analyticsEnabled, forKey: UserDefaultsKeys.analyticsEnabled) }
    }
    
    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        self.soundEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled)
        self.hapticsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hapticsEnabled)
        self.analyticsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.analyticsEnabled)
        
        // Set defaults on first launch
        if !UserDefaults.standard.hasValue(forKey: UserDefaultsKeys.notificationsEnabled) {
            self.notificationsEnabled = true
            self.soundEnabled = true
            self.hapticsEnabled = true
            self.analyticsEnabled = false
        }
    }
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        notificationsEnabled = true
        soundEnabled = true
        hapticsEnabled = true
        analyticsEnabled = false
    }
}

// MARK: - Migration Helper

class UserDefaultsMigration {
    
    /// Migrate from old key to new key
    static func migrateKey(from oldKey: String, to newKey: String) {
        guard let value = UserDefaults.standard.object(forKey: oldKey) else { return }
        UserDefaults.standard.set(value, forKey: newKey)
        UserDefaults.standard.removeObject(forKey: oldKey)
    }
    
    /// Migrate to new app version
    static func migrateToVersion(_ version: String) {
        let currentVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.appVersion) ?? "0.0.0"
        
        if currentVersion != version {
            // Perform version-specific migrations here
            switch version {
            case "1.1.0":
                // Example: Migrate old settings
                migrateToVersion1_1_0()
            case "2.0.0":
                // Example: Major version migration
                migrateToVersion2_0_0()
            default:
                break
            }
            
            // Update version
            UserDefaults.standard.set(version, forKey: UserDefaultsKeys.appVersion)
        }
    }
    
    private static func migrateToVersion1_1_0() {
        // Example migration logic
        print("Migrating to version 1.1.0")
    }
    
    private static func migrateToVersion2_0_0() {
        // Example major version migration
        print("Migrating to version 2.0.0")
    }
}
