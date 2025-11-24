//
//  ContentView.swift
//  LifeHub
//
//  Main navigation container with TabView
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            TaskManagerView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle.fill")
                }
                .tag(1)
            
            HabitTrackerView()
                .tabItem {
                    Label("Habits", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            MediaHubView()
                .tabItem {
                    Label("Media", systemImage: "play.circle.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(themeManager.currentTheme.accentColor)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .environmentObject(TaskManager())
        .environmentObject(HabitManager())
        .environmentObject(MediaManager())
}
