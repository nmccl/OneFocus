//
//  ClipboardHistoryView.swift
//  OneFocus
//
//  Clipboard history page with monitoring and management
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

import Combine

struct ClipboardHistoryView: View {
    
    // MARK: - Environment
    @EnvironmentObject var userSettings: UserSettings
    
    // MARK: - State
    @StateObject private var viewModel = ClipboardHistoryViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: ClipboardFilter = .all
    @State private var selectedItem: ClipboardItem?
    @State private var showingClearAlert = false
    
    // MARK: - Filter Enum
    enum ClipboardFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
    }
    
    // MARK: - Computed Properties
    private var filteredItems: [ClipboardItem] {
        var items = viewModel.items
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .favorites:
            items = items.filter { $0.isFavorite }
        case .recent:
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            items = items.filter { $0.timestamp > yesterday }
        }
        
        // Apply search
        if !searchText.isEmpty {
            items = items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        
        return items
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Divider()
                .background(AppConstants.Colors.divider)
            
            // Filter bar
            filterBar
            
            Divider()
                .background(AppConstants.Colors.divider)
            
            // Content
            if filteredItems.isEmpty {
                emptyState
            } else {
                clipboardList
            }
        }
        .background(AppConstants.Colors.backgroundPrimary)
        .alert("Clear History", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                viewModel.clearHistory()
            }
        } message: {
            Text("Are you sure you want to clear all clipboard history? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppConstants.Colors.textSecondary)
            
            TextField("Search clipboard", text: $searchText)
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
            
            // Monitoring status
            HStack(spacing: AppConstants.Spacing.xs) {
                Circle()
                    .fill(viewModel.isMonitoring ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isMonitoring ? "Monitoring" : "Paused")
                    .font(.system(size: AppConstants.FontSize.caption))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            
            Button(action: {
                viewModel.toggleMonitoring()
            }) {
                Image(systemName: viewModel.isMonitoring ? "pause.circle" : "play.circle")
                    .font(.system(size: 18))
                    .foregroundColor(AppConstants.Colors.textPrimary)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                showingClearAlert = true
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(Color.red.opacity(0.8))
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
            ForEach(ClipboardFilter.allCases, id: \.self) { filter in
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
            
            Text("\(filteredItems.count) items")
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(.horizontal, AppConstants.Spacing.lg)
        .padding(.vertical, AppConstants.Spacing.md)
        .background(AppConstants.Colors.backgroundPrimary)
    }
    
    // MARK: - Clipboard List
    private var clipboardList: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.Spacing.md) {
                ForEach(filteredItems) { item in
                    ClipboardItemCard(
                        item: item,
                        isSelected: selectedItem?.id == item.id,
                        onTap: {
                            selectedItem = item
                        },
                        onCopy: {
                            viewModel.copyToClipboard(item)
                        },
                        onToggleFavorite: {
                            viewModel.toggleFavorite(item)
                        },
                        onDelete: {
                            viewModel.deleteItem(item)
                        }
                    )
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
                .font(.system(size: 48))
                .foregroundColor(AppConstants.Colors.textTertiary)
            
            Text(emptyStateTitle)
                .font(.system(size: AppConstants.FontSize.title, weight: .medium))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Text(emptyStateMessage)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.xl)
            
            if !viewModel.isMonitoring {
                Button(action: {
                    viewModel.toggleMonitoring()
                }) {
                    Text("Start Monitoring")
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
        if !viewModel.isMonitoring {
            return "pause.circle"
        } else if !searchText.isEmpty {
            return "magnifyingglass"
        } else {
            return "doc.on.clipboard"
        }
    }
    
    private var emptyStateTitle: String {
        if !viewModel.isMonitoring {
            return "Monitoring Paused"
        } else if !searchText.isEmpty {
            return "No Results"
        } else {
            return "No Clipboard History"
        }
    }
    
    private var emptyStateMessage: String {
        if !viewModel.isMonitoring {
            return "Start monitoring to track your clipboard history"
        } else if !searchText.isEmpty {
            return "Try a different search term"
        } else {
            return "Copy something to get started"
        }
    }
}

// MARK: - Clipboard Item Card
struct ClipboardItemCard: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onTap: () -> Void
    let onCopy: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            HStack(alignment: .top, spacing: AppConstants.Spacing.md) {
                // Content
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                    Text(item.content)
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .lineLimit(3)
                        .textSelection(.enabled)
                    
                    HStack(spacing: AppConstants.Spacing.sm) {
                        Text(item.formattedTimestamp)
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        
                        Text("•")
                            .foregroundColor(AppConstants.Colors.textTertiary)
                        
                        Text("\(item.characterCount) characters")
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        
                        if item.wordCount > 0 {
                            Text("•")
                                .foregroundColor(AppConstants.Colors.textTertiary)
                            
                            Text("\(item.wordCount) words")
                                .font(.system(size: AppConstants.FontSize.caption))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Actions
                if isHovering || isSelected {
                    HStack(spacing: AppConstants.Spacing.sm) {
                        Button(action: onToggleFavorite) {
                            Image(systemName: item.isFavorite ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(item.isFavorite ? Color.yellow : AppConstants.Colors.textSecondary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onCopy) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(AppConstants.Colors.textPrimary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(Color.red.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(AppConstants.Spacing.lg)
        .background(isSelected ? AppConstants.Colors.backgroundTertiary : AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                .stroke(isSelected ? AppConstants.Colors.textPrimary : AppConstants.Colors.cardBorder, lineWidth: isSelected ? 1 : AppConstants.Card.borderWidth)
        )
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Clipboard History View Model
class ClipboardHistoryViewModel: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var isMonitoring: Bool = true
    
    private var timer: Timer?
    private var lastClipboardContent: String = ""
    
    init() {
        loadItems()
        if isMonitoring {
            startMonitoring()
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Methods
    func toggleMonitoring() {
        isMonitoring.toggle()
        if isMonitoring {
            startMonitoring()
        } else {
            stopMonitoring()
        }
    }
    
    func copyToClipboard(_ item: ClipboardItem) {
        #if canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        #elseif canImport(UIKit)
        UIPasteboard.general.string = item.content
        #endif
    }
    
    func toggleFavorite(_ item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
            saveItems()
        }
    }
    
    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func clearHistory() {
        items.removeAll()
        saveItems()
    }
    
    // MARK: - Private Methods
    private func startMonitoring() {
        // Get initial clipboard content
        #if canImport(AppKit)
        if let content = NSPasteboard.general.string(forType: .string) {
            lastClipboardContent = content
        }
        #elseif canImport(UIKit)
        if let content = UIPasteboard.general.string {
            lastClipboardContent = content
        }
        #endif
        
        // Start timer to check clipboard every 1 second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        #if canImport(AppKit)
        guard let content = NSPasteboard.general.string(forType: .string) else { return }
        #elseif canImport(UIKit)
        guard let content = UIPasteboard.general.string else { return }
        #endif
        
        // Only add if content has changed and is not empty
        if content != lastClipboardContent && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lastClipboardContent = content
            
            // Don't add duplicate if the same content is already at the top
            if items.first?.content != content {
                let newItem = ClipboardItem(content: content)
                items.insert(newItem, at: 0)
                
                // Limit to 100 items
                if items.count > 100 {
                    items = Array(items.prefix(100))
                }
                
                saveItems()
            }
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            items = decoded
        } 
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "clipboardHistory")
        }
    }
}

// MARK: - Preview
struct ClipboardHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardHistoryView()
            .environmentObject(UserSettings.sample)
            .frame(width: 800, height: 600)
    }
}

