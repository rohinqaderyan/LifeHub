//
//  TaskManagerView.swift
//  LifeHub
//
//  Task management with swipe gestures and notifications
//

import SwiftUI

struct TaskManagerView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddTask = false
    @State private var showingFilterSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                themeManager.currentTheme.gradient.opacity(0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Filter chips
                    filterChips
                    
                    // Task list
                    if taskManager.filteredTasks.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeManager.currentTheme.gradient)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterTasksView()
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search tasks...", text: $taskManager.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !taskManager.searchText.isEmpty {
                Button(action: { taskManager.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: taskManager.filterPriority == nil,
                    action: { taskManager.filterPriority = nil }
                )
                
                ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                    FilterChip(
                        title: priority.rawValue,
                        isSelected: taskManager.filterPriority == priority,
                        color: priority.color,
                        action: { taskManager.filterPriority = priority }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Task List
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(taskManager.filteredTasks) { task in
                    TaskRowView(task: task)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundStyle(themeManager.currentTheme.gradient)
            
            Text("No Tasks Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create a new task to get started!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddTask = true }) {
                Label("Add Task", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(themeManager.currentTheme.gradient)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Task Row View
struct TaskRowView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var themeManager: ThemeManager
    let task: Task
    @State private var offset: CGFloat = 0
    @State private var showingEditSheet = false
    
    var body: some View {
        ZStack {
            // Background actions
            HStack {
                Spacer()
                
                // Delete button
                Button(action: { deleteTask() }) {
                    VStack {
                        Image(systemName: "trash.fill")
                        Text("Delete")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                }
                .frame(maxHeight: .infinity)
                .background(Color.red)
                
                // Edit button
                Button(action: { showingEditSheet = true }) {
                    VStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                }
                .frame(maxHeight: .infinity)
                .background(Color.blue)
            }
            
            // Main content
            HStack(spacing: 16) {
                // Completion button
                Button(action: { toggleCompletion() }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        // Priority badge
                        HStack(spacing: 4) {
                            Image(systemName: task.priority.icon)
                            Text(task.priority.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(task.priority.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(task.priority.color.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Due date
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                Text(dueDate, style: .date)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = gesture.translation.width
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if gesture.translation.width < -100 {
                                offset = -160
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTaskView(task: task)
        }
    }
    
    private func toggleCompletion() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            taskManager.toggleTaskCompletion(task)
        }
    }
    
    private func deleteTask() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            taskManager.deleteTask(task)
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.TaskPriority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        let task = Task(
            title: title,
            description: description,
            priority: priority,
            isCompleted: false,
            dueDate: hasDueDate ? dueDate : nil,
            createdAt: Date(),
            tags: []
        )
        taskManager.addTask(task)
        dismiss()
    }
}

// MARK: - Edit Task View
struct EditTaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Environment(\.dismiss) var dismiss
    
    let task: Task
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.TaskPriority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                title = task.title
                description = task.description
                priority = task.priority
                hasDueDate = task.dueDate != nil
                if let date = task.dueDate {
                    dueDate = date
                }
            }
        }
    }
    
    private func saveTask() {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.description = description
        updatedTask.priority = priority
        updatedTask.dueDate = hasDueDate ? dueDate : nil
        taskManager.updateTask(updatedTask)
        dismiss()
    }
}

// MARK: - Filter Tasks View
struct FilterTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Visibility") {
                    Toggle("Show completed tasks", isOn: $taskManager.showCompletedTasks)
                }
                
                Section("Priority Filter") {
                    Button("All Priorities") {
                        taskManager.filterPriority = nil
                    }
                    
                    ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                        Button(action: {
                            taskManager.filterPriority = priority
                        }) {
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.rawValue)
                                Spacer()
                                if taskManager.filterPriority == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .foregroundColor(priority.color)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TaskManagerView()
        .environmentObject(TaskManager())
        .environmentObject(ThemeManager())
}
