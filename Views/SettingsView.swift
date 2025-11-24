//
//  SettingsView.swift
//  LifeHub
//
//  Settings with theme customization and profile
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingThemeSelector = false
    @State private var showingProfileEditor = false
    @State private var username = UserDefaults.standard.string(forKey: "username") ?? "John Doe"
    @State private var bio = UserDefaults.standard.string(forKey: "bio") ?? "Living my best life! 🚀"
    @State private var notificationsEnabled = true
    @State private var hapticEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                // Profile section
                profileSection
                
                // Appearance
                appearanceSection
                
                // Notifications
                notificationsSection
                
                // Privacy
                privacySection
                
                // Fun extras
                funExtrasSection
                
                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingThemeSelector) {
                ThemeSelectorView()
            }
            .sheet(isPresented: $showingProfileEditor) {
                ProfileEditorView(username: $username, bio: $bio)
            }
        }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(themeManager.currentTheme.gradient)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(String(username.prefix(1)))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: { showingProfileEditor = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(themeManager.currentTheme.gradient)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Appearance Section
    private var appearanceSection: some View {
        Section("Appearance") {
            // Theme selector
            Button(action: { showingThemeSelector = true }) {
                HStack {
                    Image(systemName: "paintpalette.fill")
                        .foregroundStyle(themeManager.currentTheme.gradient)
                    
                    Text("Theme")
                    
                    Spacer()
                    
                    Text(themeManager.currentTheme.name)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Dark mode toggle
            Toggle(isOn: $themeManager.isDarkMode) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.indigo)
                    Text("Dark Mode")
                }
            }
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle(isOn: $notificationsEnabled) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    Text("Push Notifications")
                }
            }
            
            Toggle(isOn: $hapticEnabled) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(.blue)
                    Text("Haptic Feedback")
                }
            }
        }
    }
    
    // MARK: - Privacy Section
    private var privacySection: some View {
        Section("Privacy") {
            NavigationLink(destination: Text("Privacy Policy")) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text("Privacy Policy")
                }
            }
            
            NavigationLink(destination: Text("Terms of Service")) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.purple)
                    Text("Terms of Service")
                }
            }
        }
    }
    
    // MARK: - Fun Extras Section
    private var funExtrasSection: some View {
        Section("Fun Extras") {
            NavigationLink(destination: TicTacToeView()) {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.red)
                    Text("Play Tic-Tac-Toe")
                }
            }
            
            NavigationLink(destination: DailyQuotesView()) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .foregroundColor(.pink)
                    Text("Daily Quotes")
                }
            }
            
            NavigationLink(destination: ChatbotView()) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.cyan)
                    Text("AI Chatbot")
                }
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text("2025.11.24")
                    .foregroundColor(.secondary)
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Rate LifeHub")
                }
            }
        }
    }
}

// MARK: - Theme Selector View
struct ThemeSelectorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(themeManager.themes) { theme in
                        ThemeCard(theme: theme)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Theme Card
struct ThemeCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let theme: AppTheme
    
    var body: some View {
        Button(action: { themeManager.selectTheme(theme) }) {
            VStack(spacing: 12) {
                // Color preview
                Circle()
                    .fill(theme.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: themeManager.currentTheme.id == theme.id ? 4 : 0)
                    )
                
                Text(theme.name)
                    .font(.subheadline)
                    .fontWeight(themeManager.currentTheme.id == theme.id ? .bold : .regular)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

// MARK: - Profile Editor View
struct ProfileEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var username: String
    @Binding var bio: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Information") {
                    TextField("Username", text: $username)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(bio, forKey: "bio")
        dismiss()
    }
}

// MARK: - Tic-Tac-Toe Game
struct TicTacToeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var board = Array(repeating: "", count: 9)
    @State private var currentPlayer = "X"
    @State private var winner: String?
    @State private var isDraw = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 30) {
            // Game status
            Text(gameStatus)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(themeManager.currentTheme.gradient)
            
            // Game board
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    GameCell(mark: board[index])
                        .onTapGesture {
                            makeMove(at: index)
                        }
                }
            }
            .padding()
            .aspectRatio(1, contentMode: .fit)
            
            // Reset button
            Button(action: resetGame) {
                Text("New Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.currentTheme.gradient)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Tic-Tac-Toe")
    }
    
    private var gameStatus: String {
        if let winner = winner {
            return "\(winner) Wins! 🎉"
        } else if isDraw {
            return "It's a Draw! 🤝"
        } else {
            return "Player \(currentPlayer)'s Turn"
        }
    }
    
    private func makeMove(at index: Int) {
        guard board[index].isEmpty && winner == nil && !isDraw else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            board[index] = currentPlayer
        }
        
        checkWinner()
        
        if winner == nil && !isDraw {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
        }
    }
    
    private func checkWinner() {
        let winPatterns = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6]             // Diagonals
        ]
        
        for pattern in winPatterns {
            let marks = pattern.map { board[$0] }
            if marks.allSatisfy({ $0 == "X" }) {
                winner = "X"
                return
            } else if marks.allSatisfy({ $0 == "O" }) {
                winner = "O"
                return
            }
        }
        
        if board.allSatisfy({ !$0.isEmpty }) {
            isDraw = true
        }
    }
    
    private func resetGame() {
        withAnimation {
            board = Array(repeating: "", count: 9)
            currentPlayer = "X"
            winner = nil
            isDraw = false
        }
    }
}

// MARK: - Game Cell
struct GameCell: View {
    @EnvironmentObject var themeManager: ThemeManager
    let mark: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .aspectRatio(1, contentMode: .fit)
            
            Text(mark)
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(mark == "X" ? Color.blue.gradient : Color.red.gradient)
        }
    }
}

// MARK: - Daily Quotes View
struct DailyQuotesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentQuote = Quote.sample()
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(themeManager.currentTheme.gradient)
                
                Text(currentQuote.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("— \(currentQuote.author)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
            
            Button(action: { currentQuote = Quote.sample() }) {
                Text("Next Quote")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.currentTheme.gradient)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Daily Quotes")
    }
}

struct Quote {
    let text: String
    let author: String
    
    static func sample() -> Quote {
        let quotes = [
            Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
            Quote(text: "Your time is limited, don't waste it living someone else's life.", author: "Steve Jobs"),
            Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
            Quote(text: "Don't let yesterday take up too much of today.", author: "Will Rogers"),
            Quote(text: "You learn more from failure than from success.", author: "Unknown"),
            Quote(text: "It's not whether you get knocked down, it's whether you get up.", author: "Vince Lombardi")
        ]
        return quotes.randomElement() ?? quotes[0]
    }
}

// MARK: - Chatbot View
struct ChatbotView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm your LifeHub assistant. How can I help you today?", isUser: false)
    ]
    @State private var inputText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Input bar
            HStack(spacing: 12) {
                TextField("Type a message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(themeManager.currentTheme.gradient)
                }
                .disabled(inputText.isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle("AI Assistant")
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMessage = ChatMessage(text: inputText, isUser: true)
        messages.append(userMessage)
        
        let userInput = inputText.lowercased()
        inputText = ""
        
        // Simple AI responses
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = generateResponse(for: userInput)
            messages.append(ChatMessage(text: response, isUser: false))
        }
    }
    
    private func generateResponse(for input: String) -> String {
        if input.contains("hello") || input.contains("hi") {
            return "Hello! How can I assist you today? 👋"
        } else if input.contains("help") {
            return "I can help you with tasks, habits, and productivity tips. What would you like to know?"
        } else if input.contains("task") {
            return "You can create tasks in the Tasks tab. Set priorities and due dates to stay organized!"
        } else if input.contains("habit") {
            return "Build better habits in the Habits tab. Track your progress and earn badges! 🏆"
        } else {
            return "That's interesting! Feel free to ask me about tasks, habits, or productivity tips."
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

struct MessageBubble: View {
    @EnvironmentObject var themeManager: ThemeManager
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.text)
                .padding()
                .background(
                    message.isUser ?
                    AnyView(themeManager.currentTheme.gradient) :
                    AnyView(Color(.systemGray5))
                )
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
            
            if !message.isUser { Spacer() }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
