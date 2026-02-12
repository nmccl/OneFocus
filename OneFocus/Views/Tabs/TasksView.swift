//
//  TasksView.swift
//  OneFocus
//
//  Task management screen with list and creation - WITH PERSISTENCE FIX
//

import SwiftUI

struct TasksView: View {
    
    // MARK: - Environment
    @EnvironmentObject var userSettings: UserSettings
    
    // MARK: - State
    @StateObject private var viewModel = TasksViewModel()
    @State private var showingNewTaskSheet = false
    @State private var selectedFilter: TaskFilter = .all
    @State private var searchText = ""
    
    // MARK: - Filter Enum
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case completed = "Completed"
    }
    
    // MARK: - Computed Properties
    private var filteredTasks: [Task] {
        var filtered = viewModel.tasks
        
        // Apply filter
        switch selectedFilter {
        case .all:
            filtered = viewModel.tasks.incomplete
        case .today:
            filtered = viewModel.tasks.dueToday
        case .completed:
            filtered = viewModel.tasks.completed
        }
        
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filtered.sortedByPriority
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header with search
            headerSection
            
            Divider()
                .background(AppConstants.Colors.divider)
            
            // Filter bar
            filterBar
            
            Divider()
                .background(AppConstants.Colors.divider)
            
            // Task list
            if filteredTasks.isEmpty {
                emptyState
            } else {
                taskList
            }
        }
        .background(AppConstants.Colors.backgroundPrimary)
        .sheet(isPresented: $showingNewTaskSheet) {
            // FIXED: Pass viewModel instead of binding
            NewTaskDetailSheet(viewModel: viewModel)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppConstants.Colors.textSecondary)
            
            TextField("Search tasks", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: AppConstants.FontSize.body))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Button(action: {
                showingNewTaskSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppConstants.Spacing.lg)
        .padding(.vertical, AppConstants.Spacing.md)
        .background(AppConstants.Colors.backgroundPrimary)
    }
    
    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                FilterChip(
                    title: filter.rawValue,
                    isSelected: selectedFilter == filter
                ) {
                    withAnimation(.easeInOut(duration: AppConstants.Animation.fast)) {
                        selectedFilter = filter
                    }

                    if userSettings.hapticEnabled {
                        HapticManager.impact(.light)
                    }
                }
            }
            Spacer()
            if selectedFilter == .completed {
                Button {
                    clearCompletedTasks()
                    if userSettings.hapticEnabled {
                        HapticManager.impact(.light)
                    }
                } label: {
                    Text("Clear Completed")
                        .font(.system(size: AppConstants.FontSize.subheadline, weight: .regular))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .padding(.horizontal, AppConstants.Spacing.md)
                        .padding(.vertical, AppConstants.Spacing.sm)
                        .background(AppConstants.Colors.backgroundSecondary)
                        .cornerRadius(AppConstants.CornerRadius.pill)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.pill)
                                .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppConstants.Spacing.lg)
        .padding(.vertical, AppConstants.Spacing.md)
        .background(AppConstants.Colors.backgroundPrimary)
    }
    
    // MARK: - Task List
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.Spacing.md) {
                ForEach(filteredTasks) { task in
                    TaskCardView(
                        task: binding(for: task),
                        viewModel: viewModel,  // FIXED: Pass viewModel
                        onDelete: {
                            viewModel.deleteTask(task)
                        }
                    )
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, AppConstants.Spacing.lg)
            .padding(.vertical, AppConstants.Spacing.lg)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            Spacer()
            
            Image(systemName: emptyStateIcon)
                .font(.system(size: 48, weight: .regular))
                .foregroundColor(AppConstants.Colors.textTertiary)
            
            Text(emptyStateTitle)
                .font(.system(size: AppConstants.FontSize.title, weight: .medium))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Text(emptyStateMessage)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.xl)
            
            if selectedFilter != .completed {
                Button(action: {
                    showingNewTaskSheet = true
                }) {
                    Text("Create Task")
                        .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.vertical, 14)
                        .background(AppConstants.Colors.primaryAccent)
                        .cornerRadius(AppConstants.CornerRadius.medium)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyStateIcon: String {
        switch selectedFilter {
        case .all:
            return searchText.isEmpty ? "checklist" : "magnifyingglass"
        case .today:
            return "calendar"
        case .completed:
            return "checkmark.circle"
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all:
            return searchText.isEmpty ? "No Tasks" : "No Results"
        case .today:
            return "Nothing Due Today"
        case .completed:
            return "No Completed Tasks"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return searchText.isEmpty ? "Create your first task to get started" : "Try a different search term"
        case .today:
            return "You're all caught up for today"
        case .completed:
            return "Complete tasks to see them here"
        }
    }
    
    // MARK: - Helper Methods
    private func binding(for task: Task) -> Binding<Task> {
        guard let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) else {
            fatalError("Task not found")
        }
        return $viewModel.tasks[index]
    }
    
    private func clearCompletedTasks() {
        // Collect completed tasks first to avoid mutating while iterating
        let completed = viewModel.tasks.filter { $0.isCompleted }
        completed.forEach { task in
            viewModel.deleteTask(task)
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: AppConstants.FontSize.subheadline, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                .padding(.horizontal, AppConstants.Spacing.md)
                .padding(.vertical, AppConstants.Spacing.sm)
                .background(isSelected ? AppConstants.Colors.primaryAccent : AppConstants.Colors.backgroundSecondary)
                .cornerRadius(AppConstants.CornerRadius.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.pill)
                        .stroke(isSelected ? Color.clear : AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Task Card View
struct TaskCardView: View {
    @Binding var task: Task
    @ObservedObject var viewModel: TasksViewModel  // FIXED: Add viewModel
    @EnvironmentObject var userSettings: UserSettings
    @State private var showingDetailSheet = false
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            // Completion checkbox
            Button(action: {
                withAnimation(.easeInOut(duration: AppConstants.Animation.fast)) {
                    // FIXED: Use viewModel method instead of direct mutation
                    viewModel.toggleTaskCompletion(task)
                }
                
                if userSettings.hapticEnabled {
                    HapticManager.impact(.light)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(task.isCompleted ? AppConstants.Colors.textTertiary : AppConstants.Colors.textPrimary)
            }
            .buttonStyle(.plain)
            
            // Task content
            Button(action: {
                showingDetailSheet = true
            }) {
                HStack(spacing: AppConstants.Spacing.md) {
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                        Text(task.title)
                            .font(.system(size: AppConstants.FontSize.body))
                            .foregroundColor(task.isCompleted ? AppConstants.Colors.textTertiary : AppConstants.Colors.textPrimary)
                            .strikethrough(task.isCompleted)
                            .lineLimit(2)
                        
                        HStack(spacing: AppConstants.Spacing.sm) {
                            Text(task.priority.rawValue)
                                .font(.system(size: AppConstants.FontSize.caption))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                            
                            Text("•")
                                .foregroundColor(AppConstants.Colors.textTertiary)
                            
                            Text(task.formattedCreatedDate)
                                .font(.system(size: AppConstants.FontSize.caption))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppConstants.Colors.textTertiary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(AppConstants.Spacing.lg)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
        )
        .sheet(isPresented: $showingDetailSheet) {
            TaskDetailSheet(task: $task, viewModel: viewModel, onDelete: onDelete)  // FIXED: Pass viewModel
        }
    }
}

// MARK: - New Task Detail Sheet
struct NewTaskDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TasksViewModel  // FIXED: Use viewModel instead of binding
    @State private var taskTitle = ""
    @State private var selectedPriority: Task.Priority = .medium
    @State private var notes = ""
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.xl) {
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("Task Title")
                            .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        
                        TextField("Enter task title", text: $taskTitle)
                            .textFieldStyle(.plain)
                            .font(.system(size: AppConstants.FontSize.body))
                            .padding(AppConstants.Spacing.md)
                            .background(AppConstants.Colors.backgroundSecondary)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("Priority")
                            .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(Task.Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("Due Date")
                            .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        
                        DatePicker("", selection: $dueDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("Notes (Optional)")
                            .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        
                        TextEditor(text: $notes)
                            .font(.system(size: AppConstants.FontSize.body))
                            .frame(height: 100)
                            .padding(AppConstants.Spacing.sm)
                            .background(AppConstants.Colors.backgroundSecondary)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                    }
                    
                    Button(action: {
                        let newTask = Task(
                            title: taskTitle,
                            dueDate: dueDate,
                            priority: selectedPriority,
                            notes: notes.isEmpty ? nil : notes
                        )
                        // FIXED: Use viewModel.addTask() instead of direct append
                        viewModel.addTask(newTask)
                        dismiss()
                    }) {
                        Text("Create Task")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(taskTitle.isEmpty ? AppConstants.Colors.textTertiary : AppConstants.Colors.primaryAccent)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                    }
                    .buttonStyle(.plain)
                    .disabled(taskTitle.isEmpty)
                }
                .padding(AppConstants.Spacing.xl)
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(idealWidth: 400, idealHeight: 450)
        .frame(minWidth: 400, maxWidth: 600, minHeight: 500, maxHeight: 800)
    }
}


// MARK: - Task Detail Sheet
struct TaskDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var task: Task
    @ObservedObject var viewModel: TasksViewModel  // FIXED: Add viewModel
    let onDelete: () -> Void
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedNotes: String = ""
    @State private var editedPriority: Task.Priority = .medium
    @State private var editedDueDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.xl) {
                    if isEditing {
                        // Edit mode
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Task Title")
                                .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                            
                            TextField("Task title", text: $editedTitle)
                                .textFieldStyle(.plain)
                                .font(.system(size: AppConstants.FontSize.body))
                                .padding(AppConstants.Spacing.md)
                                .background(AppConstants.Colors.backgroundSecondary)
                                .cornerRadius(AppConstants.CornerRadius.medium)
                        }
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Priority")
                                .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                            
                            Picker("Priority", selection: $editedPriority) {
                                ForEach(Task.Priority.allCases, id: \.self) { priority in
                                    Text(priority.rawValue).tag(priority)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Due Date")
                                .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                            
                            DatePicker("", selection: $editedDueDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Notes")
                                .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                            
                            TextEditor(text: $editedNotes)
                                .font(.system(size: AppConstants.FontSize.body))
                                .frame(height: 100)
                                .padding(AppConstants.Spacing.sm)
                                .background(AppConstants.Colors.backgroundSecondary)
                                .cornerRadius(AppConstants.CornerRadius.medium)
                        }
                    } else {
                        // View mode
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {
                            HStack {
                                Image(systemName: task.priority.icon)
                                    .foregroundColor(task.priority.color)
                                Text(task.priority.rawValue)
                                    .font(.system(size: AppConstants.FontSize.subheadline))
                                    .foregroundColor(task.priority.color)
                                Spacer()
                            }
                            
                            Text(task.title)
                                .font(.system(size: AppConstants.FontSize.title, weight: .medium))
                                .foregroundColor(AppConstants.Colors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                                HStack {
                                    Text("Created:")
                                        .foregroundColor(AppConstants.Colors.textSecondary)
                                    Text(task.formattedCreatedDate)
                                        .foregroundColor(AppConstants.Colors.textPrimary)
                                }
                                .font(.system(size: AppConstants.FontSize.body))
                                
                                HStack {
                                    Text("Due:")
                                        .foregroundColor(AppConstants.Colors.textSecondary)
                                    Text(task.formattedDueDate)
                                        .foregroundColor(AppConstants.Colors.textPrimary)
                                }
                                .font(.system(size: AppConstants.FontSize.body))
                            }
                            
                            if let notes = task.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                                    Text("Notes")
                                        .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                                        .foregroundColor(AppConstants.Colors.textSecondary)
                                    
                                    Text(notes)
                                        .font(.system(size: AppConstants.FontSize.body))
                                        .foregroundColor(AppConstants.Colors.textPrimary)
                                }
                            }
                        }
                    }
                }
                .padding(AppConstants.Spacing.xl)
            }
            .navigationTitle(isEditing ? "Edit Task" : "Task Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEditing ? "Cancel" : "Done") {
                        if isEditing {
                            isEditing = false
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Save") {
                            task.title = editedTitle
                            task.priority = editedPriority
                            task.dueDate = editedDueDate
                            task.notes = editedNotes.isEmpty ? nil : editedNotes
                            // FIXED: Save after editing
                            viewModel.updateTask(task)
                            
                            isEditing = false
                        }
                        .disabled(editedTitle.isEmpty)
                    } else {
                        Menu {
                            Button {
                                editedTitle = task.title
                                editedPriority = task.priority
                                editedDueDate = task.dueDate ?? Date()
                                editedNotes = task.notes ?? ""
                                isEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                onDelete()
                                dismiss()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .frame(idealWidth: 500, idealHeight: 650)
        .frame(minWidth: 400, maxWidth: 600, minHeight: 500, maxHeight: 800)
    }
}


