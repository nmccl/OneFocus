//
//  QuickNotesView.swift
//  OneFocus
//
//  Quick Notes page with auto-save + rich text editing + macOS hotkey quick-capture
//

import SwiftUI
import Combine

import Foundation

#if os(macOS)
import AppKit
import Carbon
#else
import UIKit
#endif


// MARK: - QuickNotesView

struct QuickNotesView: View {

    // MARK: - Environment
    @EnvironmentObject private var userSettings: UserSettings

    // MARK: - State
    @StateObject private var viewModel = QuickNotesViewModel()
    @State private var selectedNoteID: UUID?
    @State private var searchText: String = ""

    // Quick-capture
    @State private var showingQuickCapture = false
    @State private var quickCaptureDraft = QuickNoteDraft()

    // MARK: - Computed
    private var filteredNotes: [Note] {
        let notes = viewModel.notes
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return notes }
        let q = searchText.lowercased()
        return notes.filter { n in
            n.title.lowercased().contains(q) || n.content.string.lowercased().contains(q)
        }
    }

    private var selectedNoteBinding: Binding<Note>? {
        guard let id = selectedNoteID,
              let index = viewModel.notes.firstIndex(where: { $0.id == id })
        else { return nil }
        return $viewModel.notes[index]
    }

    // MARK: - Body
    var body: some View {
        Group {
            #if os(macOS)
            HSplitView {
                notesList
                    .frame(idealWidth: 320, maxWidth: 420)

                editorContainer
                    .frame(idealWidth: 600)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            #else
            NavigationSplitView {
                notesList
            } detail: {
                editorContainer
            }
            #endif
        }
        .background(AppConstants.Colors.backgroundPrimary)
        .onAppear {
            if selectedNoteID == nil {
                selectedNoteID = viewModel.notes.first?.id
            }
            #if os(macOS)
            QuickNoteHotkeyCenter.shared.configureIfNeeded(userSettings: userSettings)
            #endif
        }
        .onChange(of: userSettings.quickNoteHotkeyEnabled) { _, _ in
            #if os(macOS)
            QuickNoteHotkeyCenter.shared.configureIfNeeded(userSettings: userSettings)
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .oneFocusQuickNoteHotkeyFired)) { _ in
            guard userSettings.quickNoteHotkeyEnabled else { return }
            presentQuickCapture()
        }
        .sheet(isPresented: $showingQuickCapture, onDismiss: {
            // When closing, if user typed anything, save it.
            commitQuickCaptureIfNeeded()
        }) {
            QuickNoteCaptureView(
                draft: $quickCaptureDraft,
                onCancel: {
                    showingQuickCapture = false
                },
                onSave: {
                    commitQuickCaptureIfNeeded(force: true)
                    showingQuickCapture = false
                }
            )
            .environmentObject(userSettings)
            .frame(idealWidth: 640, idealHeight: 420)
        }
    }

    // MARK: - Notes List
    private var notesList: some View {
        VStack(spacing: 0) {
            header
            Divider().background(AppConstants.Colors.divider)

            if filteredNotes.isEmpty {
                emptyListState
            } else {
                List(selection: $selectedNoteID) {
                    ForEach(filteredNotes, id: \.id) { note in
                        NoteRowView(note: note, isSelected: selectedNoteID == note.id)
                            .tag(note.id)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppConstants.Colors.backgroundSecondary)
            }
        }
        .background(AppConstants.Colors.backgroundSecondary)
    }

    private var header: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppConstants.Colors.textSecondary)

            TextField("Search notes", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Button {
                let new = viewModel.createNote()
                selectedNoteID = new.id
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.md)
    }

    private var emptyListState: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            Spacer()
            Image(systemName: "note.text")
                .font(.system(size: 40))
                .foregroundColor(AppConstants.Colors.textTertiary)
            Text(searchText.isEmpty ? "No Notes" : "No Results")
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.backgroundSecondary)
    }

    // MARK: - Editor Container
    private var editorContainer: some View {
        Group {
            if let noteBinding = selectedNoteBinding {
                NoteEditorView(
                    note: noteBinding,
                    onSave: { updated in
                        viewModel.updateNote(updated)
                    },
                    onDelete: {
                        let deletingID = noteBinding.wrappedValue.id
                        viewModel.deleteNote(noteBinding.wrappedValue)
                        if selectedNoteID == deletingID {
                            selectedNoteID = viewModel.notes.first?.id
                        }
                    }
                )
            } else {
                emptyEditorState
            }
        }
        .background(AppConstants.Colors.backgroundPrimary)
    }

    private var emptyEditorState: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            Image(systemName: "note.text")
                .font(.system(size: 64))
                .foregroundColor(AppConstants.Colors.textTertiary)

            Text("Select a note or create a new one")
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)

            Button {
                let new = viewModel.createNote()
                selectedNoteID = new.id
            } label: {
                Text("Create Note")
                    .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppConstants.Spacing.xl)
                    .padding(.vertical, 14)
                    .background(AppConstants.Colors.primaryAccent)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.backgroundPrimary)
    }

    // MARK: - Quick Capture
    private func presentQuickCapture() {
        quickCaptureDraft = QuickNoteDraft()
        showingQuickCapture = true
    }

    private func commitQuickCaptureIfNeeded(force: Bool = false) {
        let title = quickCaptureDraft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let body  = quickCaptureDraft.body.trimmingCharacters(in: .whitespacesAndNewlines)

        guard force || !title.isEmpty || !body.isEmpty else { return }

        var note = viewModel.createNote()
        if !title.isEmpty { note.title = title }
        note.content = NSAttributedString(string: body)
        note.modifiedDate = Date()
        viewModel.updateNote(note)
        selectedNoteID = note.id
    }
}

// MARK: - Note Row View

struct NoteRowView: View {
    let note: Note
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
            Text(note.title)
                .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .lineLimit(1)

            Text(note.preview)
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .lineLimit(2)

            Text(note.formattedModifiedDate)
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundColor(AppConstants.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.sm)
        .background(isSelected ? AppConstants.Colors.backgroundTertiary : Color.clear)
        .cornerRadius(AppConstants.CornerRadius.small)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

// MARK: - Note Editor View

struct NoteEditorView: View {
    @Binding var note: Note
    let onSave: (Note) -> Void
    let onDelete: () -> Void

    @State private var title: String
    @State private var content: NSAttributedString

    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderline: Bool = false

    @State private var showingDeleteAlert = false

    #if os(macOS)
    @State private var macEditor: NSTextView?
    #endif

    init(note: Binding<Note>, onSave: @escaping (Note) -> Void, onDelete: @escaping () -> Void) {
        self._note = note
        self.onSave = onSave
        self.onDelete = onDelete
        self._title = State(initialValue: note.wrappedValue.title)
        self._content = State(initialValue: note.wrappedValue.content)
    }

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider().background(AppConstants.Colors.divider)
            editorToolbar
            Divider().background(AppConstants.Colors.divider)

            #if os(macOS)
            RichTextEditorMac(
                attributedText: $content,
                onTextChange: { autoSave() },
                textViewProvider: { tv in
                    self.macEditor = tv
                }
            )
            .padding(AppConstants.Spacing.xl)
            #else
            RichTextEditorIOS(attributedText: $content, onTextChange: { autoSave() })
                .padding(AppConstants.Spacing.xl)
            #endif
        }
        .background(AppConstants.Colors.backgroundPrimary)
        .onChange(of: note.id) { _, _ in
            title = note.title
            content = note.content
        }
        .onChange(of: note.title) { _, newValue in
            if title != newValue { title = newValue }
        }
        .onChange(of: note.content) { _, newValue in
            if content != newValue { content = newValue }
        }
    }

    private var titleBar: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            TextField("Note Title", text: $title)
                .textFieldStyle(.plain)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .onChange(of: title) { _, _ in autoSave() }

            Spacer()

            Button {
                autoSave()
            } label: {
                Text("Save")
                    .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppConstants.Spacing.lg)
                    .padding(.vertical, 10)
                    .background(AppConstants.Colors.primaryAccent)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
            .buttonStyle(.plain)

            Button {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(Color.red.opacity(0.85))
                    .padding(10)
                    .background(AppConstants.Colors.backgroundSecondary)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
            .buttonStyle(.plain)
            .alert("Delete Note", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { onDelete() }
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
        }
        .padding(.horizontal, AppConstants.Spacing.xl)
        .padding(.top, AppConstants.Spacing.xl)
        .padding(.bottom, AppConstants.Spacing.md)
    }

    private var editorToolbar: some View {
        HStack(spacing: AppConstants.Spacing.md) {

            ToolbarButton(icon: "bold", isActive: isBold) {
                isBold.toggle()
                toggleBold()
            }

            ToolbarButton(icon: "italic", isActive: isItalic) {
                isItalic.toggle()
                toggleItalic()
            }

            ToolbarButton(icon: "underline", isActive: isUnderline) {
                isUnderline.toggle()
                toggleUnderline()
            }

            Divider().frame(height: 20).background(AppConstants.Colors.divider)

            ToolbarButton(icon: "list.bullet") { insertText("\n• ") }
            ToolbarButton(icon: "list.number") { insertText("\n1. ") }
            ToolbarButton(icon: "checklist") { insertText("\n☐ ") }

            Divider().frame(height: 20).background(AppConstants.Colors.divider)

            Menu {
                Button("Heading 1") { insertText("\n# ") }
                Button("Heading 2") { insertText("\n## ") }
                Button("Heading 3") { insertText("\n### ") }
            } label: {
                Image(systemName: "textformat.size")
                    .font(.system(size: 14))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .frame(width: 24, height: 24)
            }
            .menuStyle(.borderlessButton)

            ToolbarButton(icon: "quote.opening") { insertText("\n> ") }
            ToolbarButton(icon: "link") { insertText("[Link Text](https://example.com)") }

            Spacer()
        }
        .padding(.horizontal, AppConstants.Spacing.xl)
        .padding(.vertical, AppConstants.Spacing.sm)
        .background(AppConstants.Colors.backgroundSecondary)
    }

    // MARK: - Save
    private func autoSave() {
        var updated = note
        updated.title = title
        updated.content = content
        updated.modifiedDate = Date()
        note = updated
        onSave(updated)
    }

    // MARK: - Insert / Formatting

    private func insertText(_ text: String) {
        #if os(macOS)
        if let tv = macEditor {
            tv.insertText(text, replacementRange: tv.selectedRange())
            content = tv.attributedString()
            autoSave()
            return
        }
        #endif

        // Fallback: append to end
        let new = NSMutableAttributedString(attributedString: content)
        new.append(NSAttributedString(string: text))
        content = new
        autoSave()
    }

    private func toggleBold() {
        #if os(macOS)
        guard let tv = macEditor else { return }
        applyFontTrait(tv: tv, trait: .boldFontMask)
        #else
        applyTypingAttributeIOS(.bold)
        #endif
    }

    private func toggleItalic() {
        #if os(macOS)
        guard let tv = macEditor else { return }
        applyFontTrait(tv: tv, trait: .italicFontMask)
        #else
        applyTypingAttributeIOS(.italic)
        #endif
    }

    private func toggleUnderline() {
        #if os(macOS)
        guard let tv = macEditor else { return }
        let range = tv.selectedRange()
        guard range.length > 0 else { return }
        let storage = tv.textStorage ?? NSTextStorage()
        let current = storage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int ?? 0
        let next = (current == 0) ? NSUnderlineStyle.single.rawValue : 0
        storage.addAttribute(.underlineStyle, value: next, range: range)
        tv.didChangeText()
        content = tv.attributedString()
        autoSave()
        #else
        applyTypingAttributeIOS(.underline)
        #endif
    }

    #if os(macOS)
    private func applyFontTrait(tv: NSTextView, trait: NSFontTraitMask) {
        let range = tv.selectedRange()
        guard range.length > 0 else { return }

        let storage = tv.textStorage ?? NSTextStorage()
        let fontManager = NSFontManager.shared

        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let hasTrait = fontManager.traits(of: currentFont).contains(trait)
            let newFont: NSFont

            if hasTrait {
                newFont = fontManager.convert(currentFont, toNotHaveTrait: trait)
            } else {
                newFont = fontManager.convert(currentFont, toHaveTrait: trait)
            }
            storage.addAttribute(.font, value: newFont, range: subRange)
        }
        storage.endEditing()

        tv.didChangeText()
        content = tv.attributedString()
        autoSave()
    }
    #endif

    #if !os(macOS)
    private enum IOSTypingStyle { case bold, italic, underline }

    // iOS: apply style to selected text if possible; otherwise this is a no-op (UITextView handles typing attributes internally)
    private func applyTypingAttributeIOS(_ style: IOSTypingStyle) {
        // RichTextEditorIOS uses UITextView; it will keep selection/attributes.
        // We simply trigger save; user edits will be captured by the editor.
        autoSave()
    }
    #endif
}

// MARK: - Toolbar Button

struct ToolbarButton: View {
    let icon: String
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isActive ? AppConstants.Colors.primaryAccent : AppConstants.Colors.textPrimary)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - RichTextEditor (macOS)

#if os(macOS)
struct RichTextEditorMac: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    let onTextChange: () -> Void
    let textViewProvider: (NSTextView) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textViewProvider(textView)

        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.font = NSFont.systemFont(ofSize: 16)
        textView.textColor = NSColor.textColor
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.textStorage?.setAttributedString(attributedText)

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tv = nsView.documentView as? NSTextView else { return }
        if tv.attributedString() != attributedText {
            tv.textStorage?.setAttributedString(attributedText)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditorMac
        init(_ parent: RichTextEditorMac) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            parent.attributedText = tv.attributedString()
            parent.onTextChange()
        }
    }
}
#endif

// MARK: - RichTextEditor (iOS)

#if !os(macOS)
struct RichTextEditorIOS: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    let onTextChange: () -> Void

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv.attributedText = attributedText
        tv.font = UIFont.systemFont(ofSize: 16)
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditorIOS
        init(_ parent: RichTextEditorIOS) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText ?? NSAttributedString(string: "")
            parent.onTextChange()
        }
    }
}
#endif

// MARK: - Quick Notes View Model

final class QuickNotesViewModel: ObservableObject {
    @Published var notes: [Note] = []

    init() { loadNotes() }

    func createNote() -> Note {
        let newNote = Note()
        notes.insert(newNote, at: 0)
        saveNotes()
        return newNote
    }

    func updateNote(_ note: Note) {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[idx] = note
        saveNotes()
    }

    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }

    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "quickNotes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        } else {
            notes = Note.sampleList
        }
    }

    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "quickNotes")
        }
    }
}

// MARK: - Quick Capture Modal

struct QuickNoteDraft: Equatable {
    var title: String = ""
    var body: String = ""
}

struct QuickNoteCaptureView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @Binding var draft: QuickNoteDraft

    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        ZStack {
            AppConstants.Colors.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider().background(AppConstants.Colors.divider)

                VStack(spacing: AppConstants.Spacing.lg) {
                    TextField("Title (optional)", text: $draft.title)
                        .textFieldStyle(.plain)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.top, AppConstants.Spacing.xl)

                    TextEditor(text: $draft.body)
                        .font(.system(size: 16))
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.bottom, AppConstants.Spacing.xl)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
            }
            .background(AppConstants.Colors.backgroundPrimary)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quick Note")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                Text("Capture now, it will be saved to Quick Notes.")
                    .font(.system(size: AppConstants.FontSize.caption))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }

            Spacer()

            Button("Cancel") { onCancel() }
                .buttonStyle(.plain)
                .foregroundColor(AppConstants.Colors.textSecondary)

            Button {
                onSave()
            } label: {
                Text("Save")
                    .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppConstants.Spacing.lg)
                    .padding(.vertical, 10)
                    .background(AppConstants.Colors.primaryAccent)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppConstants.Spacing.xl)
        .padding(.vertical, AppConstants.Spacing.lg)
        .background(AppConstants.Colors.backgroundPrimary)
    }
}

// MARK: - UserSettings keys for Hotkey (stored in UserDefaults)

extension UserSettings {
    private static let quickNoteHotkeyEnabledKey = "quickNoteHotkeyEnabled"
    private static let quickNoteHotkeyKeyCodeKey = "quickNoteHotkeyKeyCode"
    private static let quickNoteHotkeyModifiersKey = "quickNoteHotkeyModifiers"

    /// macOS only: enable/disable global hotkey for Quick Note capture.
    var quickNoteHotkeyEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Self.quickNoteHotkeyEnabledKey) as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: Self.quickNoteHotkeyEnabledKey) }
    }

    /// macOS only: key code (Carbon).
    var quickNoteHotkeyKeyCode: UInt32 {
        get { UInt32(UserDefaults.standard.integer(forKey: Self.quickNoteHotkeyKeyCodeKey)) }
        set { UserDefaults.standard.set(Int(newValue), forKey: Self.quickNoteHotkeyKeyCodeKey) }
    }

    /// macOS only: Carbon modifiers (cmd/opt/ctrl/shift).
    var quickNoteHotkeyModifiers: UInt32 {
        get {
            let v = UserDefaults.standard.integer(forKey: Self.quickNoteHotkeyModifiersKey)
            return v == 0 ? (UInt32(cmdKey) | UInt32(optionKey)) : UInt32(v) // default: ⌥⌘
        }
        set { UserDefaults.standard.set(Int(newValue), forKey: Self.quickNoteHotkeyModifiersKey) }
    }
}

// MARK: - Hotkey Center (macOS global hotkey → posts notification)

#if os(macOS)
final class QuickNoteHotkeyCenter {
    static let shared = QuickNoteHotkeyCenter()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    private init() {}

    func configureIfNeeded(userSettings: UserSettings) {
        unregister()

        guard userSettings.quickNoteHotkeyEnabled else { return }

        // Choose a safe default if none set:
        // keyCode 40 = kVK_ANSI_K (commonly used in apps), modifiers default ⌥⌘ via UserSettings getter above.
        if userSettings.quickNoteHotkeyKeyCode == 0 {
            userSettings.quickNoteHotkeyKeyCode = UInt32(kVK_ANSI_K)
        }

        register(
            keyCode: userSettings.quickNoteHotkeyKeyCode,
            modifiers: userSettings.quickNoteHotkeyModifiers
        )
    }

    private func register(keyCode: UInt32, modifiers: UInt32) {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        // Install handler once
        if eventHandlerRef == nil {
            let handler: EventHandlerUPP = { _, _, _ in
                NotificationCenter.default.post(name: .oneFocusQuickNoteHotkeyFired, object: nil)
                return noErr
            }

            InstallEventHandler(
                GetEventDispatcherTarget(),
                handler,
                1,
                &eventType,
                nil,
                &eventHandlerRef
            )
        }

        var hotKeyID = EventHotKeyID(signature: OSType(0x4F4E4651), id: 1) // "ONFQ"
        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
    }

    private func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }
}
#endif

// MARK: - Notifications

extension Notification.Name {
    static let oneFocusQuickNoteHotkeyFired = Notification.Name("oneFocus.quickNoteHotkeyFired")
}

// MARK: - Preview

struct QuickNotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuickNotesView()
            .environmentObject(UserSettings.sample)
            .frame(width: 1100, height: 650)
    }
}

