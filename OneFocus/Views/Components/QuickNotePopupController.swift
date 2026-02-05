//
//  QuickNotePopupController.swift
//  OneFocus
//
//  Created by Noah McClung on 1/2/26.
//


#if os(macOS)
import SwiftUI
import AppKit

@MainActor
final class QuickNotePopupController {
    static let shared = QuickNotePopupController()

    private var window: NSWindow?

    func show(onSave: @escaping (_ title: String, _ body: String) -> Void) {
        if window != nil {
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let root = QuickNotePopupView { title, body in
            onSave(title, body)
            self.close()
        } onCancel: {
            self.close()
        }

        let hosting = NSHostingView(rootView: root)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 360),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "Quick Note"
        win.isReleasedWhenClosed = false
        win.center()
        win.contentView = hosting

        self.window = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        window?.close()
        window = nil
    }
}

private struct QuickNotePopupView: View {
    @EnvironmentObject private var userSettings: UserSettings

    @State private var title: String = ""
    @State private var bodyText: String = ""

    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            AppConstants.Colors.backgroundPrimary.ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                Text("Quick Note")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)

                TextField("Title", text: $title)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppConstants.Colors.cardBackground)
                    .cornerRadius(AppConstants.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                            .stroke(AppConstants.Colors.cardBorder, lineWidth: 0.5)
                    )

                TextEditor(text: $bodyText)
                    .font(.system(size: 15))
                    .padding(10)
                    .background(AppConstants.Colors.cardBackground)
                    .cornerRadius(AppConstants.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                            .stroke(AppConstants.Colors.cardBorder, lineWidth: 0.5)
                    )

                HStack {
                    Button("Cancel") { onCancel() }
                        .buttonStyle(.plain)
                        .foregroundColor(AppConstants.Colors.textSecondary)

                    Spacer()

                    Button("Save") {
                        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalBody  = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(finalTitle.isEmpty ? "Untitled" : finalTitle, finalBody)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppConstants.Spacing.lg)
                    .padding(.vertical, 10)
                    .background(AppConstants.Colors.primaryAccent)
                    .cornerRadius(AppConstants.CornerRadius.medium)
                }
            }
            .padding(AppConstants.Spacing.xl)
        }
    }
}
#endif