// ===============================
// FIX 2: RichTextController.swift
// - Fixes:
//   • “RichTextController does not conform to ObservableObject”
//   • NSTextView no member toggleBoldface/toggleItalics/toggleUnderline
//   • “‘nil’ requires a contextual type”
// ===============================

import SwiftUI
#if os(macOS)
import AppKit
#endif
import Combine

@MainActor
final class RichTextController: ObservableObject {

    @Published var attributedText: NSAttributedString = NSAttributedString(string: "")

    fileprivate weak var textView: NSTextView?

    func setText(_ string: String) {
        attributedText = NSAttributedString(string: string)
        textView?.textStorage?.setAttributedString(attributedText)
    }

    func toggleBold() {
        guard let tv = textView, let storage = tv.textStorage else { return }
        let range = tv.selectedRange()
        guard range.length > 0 else { return }

        let fm = NSFontManager.shared
        var shouldAddBold = true

        storage.enumerateAttribute(.font, in: range, options: []) { value, _, stop in
            if let font = value as? NSFont {
                let hasBold = font.fontDescriptor.symbolicTraits.contains(.bold)
                if hasBold { shouldAddBold = false; stop.pointee = true }
            }
        }

        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range, options: []) { value, subrange, _ in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: tv.font?.pointSize ?? NSFont.systemFontSize)
            let newFont: NSFont
            if shouldAddBold {
                newFont = fm.convert(currentFont, toHaveTrait: .boldFontMask)
            } else {
                newFont = fm.convert(currentFont, toNotHaveTrait: .boldFontMask)
            }
            storage.addAttribute(.font, value: newFont, range: subrange)
        }
        storage.endEditing()
        tv.didChangeText()
        attributedText = tv.attributedString()
    }

    func toggleItalic() {
        guard let tv = textView, let storage = tv.textStorage else { return }
        let range = tv.selectedRange()
        guard range.length > 0 else { return }

        let fm = NSFontManager.shared
        var shouldAddItalic = true

        storage.enumerateAttribute(.font, in: range, options: []) { value, _, stop in
            if let font = value as? NSFont {
                let hasItalic = font.fontDescriptor.symbolicTraits.contains(.italic)
                if hasItalic { shouldAddItalic = false; stop.pointee = true }
            }
        }

        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range, options: []) { value, subrange, _ in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: tv.font?.pointSize ?? NSFont.systemFontSize)
            let newFont: NSFont
            if shouldAddItalic {
                newFont = fm.convert(currentFont, toHaveTrait: .italicFontMask)
            } else {
                newFont = fm.convert(currentFont, toNotHaveTrait: .italicFontMask)
            }
            storage.addAttribute(.font, value: newFont, range: subrange)
        }
        storage.endEditing()
        tv.didChangeText()
        attributedText = tv.attributedString()
    }

    func toggleUnderline() {
        guard let tv = textView else { return }
        let range = tv.selectedRange()
        guard range.length > 0, let storage = tv.textStorage else { return }
        var shouldUnderline = true
        storage.enumerateAttribute(.underlineStyle, in: range, options: []) { value, _, stop in
            if let style = value as? NSNumber, style.intValue != 0 {
                shouldUnderline = false
                stop.pointee = true
            }
        }
        let newStyle: NSUnderlineStyle = shouldUnderline ? .single : []
        storage.addAttribute(.underlineStyle, value: newStyle.rawValue, range: range)
        tv.didChangeText()
        // Keep published text in sync
        attributedText = tv.attributedString()
    }
}

// MARK: - Editor View

struct RichTextEditor: NSViewRepresentable {
    @ObservedObject var controller: RichTextController

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.usesAdaptiveColorMappingForDarkAppearance = true
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.font = NSFont.systemFont(ofSize: 15)

        textView.textStorage?.setAttributedString(controller.attributedText)

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.documentView = textView

        controller.textView = textView

        // Keep controller in sync
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.textDidChange(_:)),
            name: NSText.didChangeNotification,
            object: textView
        )

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tv = nsView.documentView as? NSTextView else { return }
        if controller.textView !== tv { controller.textView = tv }

        // Only push changes if they differ, avoids cursor jumping
        if tv.attributedString() != controller.attributedText {
            tv.textStorage?.setAttributedString(controller.attributedText)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }

    final class Coordinator: NSObject {
        let controller: RichTextController

        init(controller: RichTextController) {
            self.controller = controller
        }

        @objc func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            controller.attributedText = tv.attributedString()
        }
    }
}
