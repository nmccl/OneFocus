//
//  HomeView.swift
//  OneFocus
//
//  Home dashboard screen with today's focus and quick actions
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Environment
    @EnvironmentObject var userSettings: UserSettings
    
    // MARK: - Bindings
    @Binding var selectedTab: MainView.NavigationTab
    
    // MARK: - State
    @StateObject private var tasksViewModel = TasksViewModel()
    @StateObject private var focusViewModel = FocusViewModel()
    @State private var showingNewTaskSheet = false
    @State private var showingStatsSheet = false
    
    // MARK: - Computed Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    private var todaysTasks: [Task] {
        tasksViewModel.tasks.dueToday
    }
    
    private var completedTodayCount: Int {
        tasksViewModel.tasks.filter { $0.isDueToday && $0.isCompleted }.count
    }
    
    private var totalTodayCount: Int {
        todaysTasks.count
    }
    
    private var progressPercentage: Double {
        guard totalTodayCount > 0 else { return 0 }
        return Double(completedTodayCount) / Double(totalTodayCount)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.xl) {
                // Greeting Header
                greetingHeader
                
                // Today's Focus Card
                todaysFocusCard
                
                // Quick Actions
                quickActionsSection
                
                // Task Summary
                taskSummaryCard
                
                Spacer(minLength: AppConstants.Spacing.xl)
            }
            .padding(.horizontal, AppConstants.Spacing.xl)
            .padding(.top, AppConstants.Spacing.xl)
        }
        .background(AppConstants.Colors.backgroundPrimary.ignoresSafeArea())
        .sheet(isPresented: $showingNewTaskSheet) {
            NewTaskSheet(tasks: $tasksViewModel.tasks)
        }
        .sheet(isPresented: $showingStatsSheet) {
            StatsSheet()
        }
    }
    
    // MARK: - Greeting Header
    private var greetingHeader: some View {
        VStack(alignment: .center, spacing: AppConstants.Spacing.xs) {
            Text("\(greeting), \(userSettings.userName)")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Text(Date().formatted(date: .long, time: .omitted))
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Today's Focus Card
    private var todaysFocusCard: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            if focusViewModel.isSessionActive {
                // Active session
                VStack(spacing: AppConstants.Spacing.lg) {
                    Text("Focus Session Active")
                        .font(.system(size: AppConstants.FontSize.headline, weight: .medium))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                    
                    Text(focusViewModel.formattedTimeRemaining)
                        .font(.system(size: 48, weight: .regular, design: .rounded))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .monospacedDigit()
                    
                    Button(action: {
                        selectedTab = .focus
                        if userSettings.hapticEnabled {
                            HapticManager.impact(.light)
                        }
                    }) {
                        Text("View Session")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppConstants.Colors.primaryAccent)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppConstants.Spacing.xl)
                .frame(maxWidth: .infinity)
                .background(AppConstants.Colors.cardBackground)
                .cornerRadius(AppConstants.CornerRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
                )
            } else {
                // No active session
                VStack(spacing: AppConstants.Spacing.lg) {
                    Text("Ready to Focus")
                        .font(.system(size: AppConstants.FontSize.title, weight: .medium))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                    
                    Text("Start a focus session")
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    
                    Button(action: {
                        selectedTab = .focus
                        if userSettings.hapticEnabled {
                            HapticManager.impact(.medium)
                        }
                    }) {
                        Text("Start Focus")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppConstants.Colors.primaryAccent)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppConstants.Spacing.xl)
                .frame(maxWidth: .infinity)
                .background(AppConstants.Colors.cardBackground)
                .cornerRadius(AppConstants.CornerRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
                )
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            Text("Quick Actions")
                .font(.system(size: AppConstants.FontSize.headline, weight: .medium))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            HStack(spacing: AppConstants.Spacing.md) {
                QuickActionButton(
                    icon: "plus",
                    title: "New Task"
                ) {
                    showingNewTaskSheet = true
                    if userSettings.hapticEnabled {
                        HapticManager.impact(.light)
                    }
                }
                
                QuickActionButton(
                    icon: "clock",
                    title: "History"
                ) {
                    selectedTab = .history
                    if userSettings.hapticEnabled {
                        HapticManager.impact(.light)
                    }
                }
                
                QuickActionButton(
                    icon: "chart.bar",
                    title: "Stats"
                ) {
                    showingStatsSheet = true
                    if userSettings.hapticEnabled {
                        HapticManager.impact(.light)
                    }
                }
            }
        }
    }
    
    // MARK: - Task Summary Card
    private var taskSummaryCard: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {
            HStack {
                Text("Today's Tasks")
                    .font(.system(size: AppConstants.FontSize.headline, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Spacer()
                
                Text("\(completedTodayCount) of \(totalTodayCount)")
                    .font(.system(size: AppConstants.FontSize.subheadline))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppConstants.Colors.backgroundTertiary)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(AppConstants.Colors.textPrimary)
                        .frame(width: geometry.size.width * progressPercentage, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: AppConstants.Animation.normal), value: progressPercentage)
                }
            }
            .frame(height: 4)
            
            if totalTodayCount > 0 {
                VStack(spacing: AppConstants.Spacing.sm) {
                    ForEach(todaysTasks.prefix(3)) { task in
                        TaskRowPreview(task: task) {
                            tasksViewModel.toggleTaskCompletion(task)
                        }
                    }
                    
                    if totalTodayCount > 3 {
                        Button(action: {
                            selectedTab = .tasks
                            if userSettings.hapticEnabled {
                                HapticManager.impact(.light)
                            }
                        }) {
                            HStack {
                                Text("View all tasks")
                                    .font(.system(size: AppConstants.FontSize.subheadline))
                                    .foregroundColor(AppConstants.Colors.textSecondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppConstants.Colors.textTertiary)
                            }
                            .padding(.top, AppConstants.Spacing.xs)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("No tasks for today")
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppConstants.Spacing.lg)
            }
        }
        .padding(AppConstants.Spacing.lg)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
        )
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppConstants.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .frame(height: 40)
                
                Text(title)
                    .font(.system(size: AppConstants.FontSize.subheadline))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppConstants.Spacing.lg)
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(AppConstants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                    .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Task Row Preview
struct TaskRowPreview: View {
    let task: Task
    let onToggle: () -> Void
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            Button(action: {
                onToggle()
                if userSettings.hapticEnabled {
                    HapticManager.impact(.light)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(task.isCompleted ? AppConstants.Colors.textTertiary : AppConstants.Colors.textPrimary)
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(task.isCompleted ? AppConstants.Colors.textTertiary : AppConstants.Colors.textPrimary)
                .strikethrough(task.isCompleted)
                .lineLimit(1)
            
            Spacer()
            
            Text(task.priority.rawValue)
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(.vertical, AppConstants.Spacing.xs)
    }
}

// MARK: - New Task Sheet
struct NewTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var tasks: [Task]
    @State private var taskTitle = ""
    @State private var selectedPriority: Task.Priority = .medium
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
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
                
                Spacer()
                
                Button(action: {
                    let newTask = Task(
                        
                        title: taskTitle,
                        dueDate: Date(),
                        priority: selectedPriority,
                        notes: notes.isEmpty ? nil : notes,
                        
                        
                    )
                    tasks.append(newTask)
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
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 500)
    }
}

// MARK: - Stats Sheet
struct StatsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.xl) {
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                        Text("Focus Statistics")
                            .font(.system(size: AppConstants.FontSize.title, weight: .semibold))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                        
                        Text("Track your productivity and focus time")
                            .font(.system(size: AppConstants.FontSize.body))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Stats cards would go here
                    VStack(spacing: AppConstants.Spacing.lg) {
                        statsCard(title: "Today's Focus", value: "0h 0m", icon: "brain.head.profile")
                        statsCard(title: "This Week", value: "0h 0m", icon: "calendar")
                        statsCard(title: "Total Sessions", value: "0", icon: "checkmark.circle")
                    }
                }
                .padding(AppConstants.Spacing.xl)
            }
            .background(AppConstants.Colors.backgroundPrimary)
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
    
    private func statsCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: AppConstants.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.subheadline))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                
                Text(value)
                    .font(.system(size: AppConstants.FontSize.title, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(AppConstants.Spacing.lg)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
        )
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(.home))
            .environmentObject(UserSettings.sample)
            .frame(width: 800, height: 600)
    }
}
