//
//  LifeHubApp.swift
//  LifeHub
//
//  Created on November 24, 2025
//  A modern, interactive iOS app with multiple features
//

import SwiftUI

@main
struct LifeHubApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var taskManager = TaskManager()
    @StateObject private var habitManager = HabitManager()
    @StateObject private var mediaManager = MediaManager()
    
    init() {
        // Configure app appearance
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(taskManager)
                .environmentObject(habitManager)
                .environmentObject(mediaManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
    
    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
