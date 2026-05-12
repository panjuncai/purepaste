import AppKit
import Foundation

final class ClipboardFormatterStripper: NSObject, NSApplicationDelegate {
    private enum DefaultsKey {
        static let preserveFormatting = "preserveFormatting"
    }

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var timer: Timer?
    private var statusItem: NSStatusItem?
    private let defaults = UserDefaults.standard
    private var preserveFormatting = false
    private weak var statusMenuItem: NSMenuItem?
    private weak var preserveFormattingMenuItem: NSMenuItem?

    private let publicRTF = NSPasteboard.PasteboardType("public.rtf")
    private let flatRTFD = NSPasteboard.PasteboardType("com.apple.flat-rtfd")
    private let publicHTML = NSPasteboard.PasteboardType("public.html")
    private let appleHTML = NSPasteboard.PasteboardType("Apple HTML pasteboard type")
    private let nextRTF = NSPasteboard.PasteboardType("NeXT Rich Text Format v1.0 pasteboard type")

    private var richTextTypes: [NSPasteboard.PasteboardType] {
        [
            .rtf,
            .rtfd,
            .html,
            publicRTF,
            flatRTFD,
            publicHTML,
            appleHTML,
            nextRTF
        ]
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        preserveFormatting = defaults.bool(forKey: DefaultsKey.preserveFormatting)
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        startMonitoringClipboard()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "PP"

        let menu = NSMenu()
        let statusMenuItem = NSMenuItem(title: "PurePaste: On", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        self.statusMenuItem = statusMenuItem

        let preserveFormattingMenuItem = NSMenuItem(
            title: "Preserve Formatting",
            action: #selector(togglePreserveFormatting),
            keyEquivalent: ""
        )
        preserveFormattingMenuItem.target = self
        preserveFormattingMenuItem.state = .off
        menu.addItem(preserveFormattingMenuItem)
        self.preserveFormattingMenuItem = preserveFormattingMenuItem

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit PurePaste", action: #selector(quit), keyEquivalent: "q"))

        item.menu = menu
        statusItem = item
        updateStatusUI()
    }

    private func startMonitoringClipboard() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(checkClipboard),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer!, forMode: .common)
    }

    @objc private func checkClipboard() {
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else {
            return
        }

        lastChangeCount = currentChangeCount

        guard !preserveFormatting else {
            return
        }

        guard pasteboardContainsRichText(),
              let text = plainText() else {
            return
        }

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    private func pasteboardContainsRichText() -> Bool {
        let availableTypes = Set(pasteboard.types ?? [])
        return richTextTypes.contains { availableTypes.contains($0) }
    }

    private func plainText() -> String? {
        if let text = pasteboard.string(forType: .string) {
            return text
        }

        return textFromRichRepresentation()
    }

    private func textFromRichRepresentation() -> String? {
        for pasteboardType in richTextTypes {
            guard let data = pasteboard.data(forType: pasteboardType),
                  let documentType = documentType(for: pasteboardType) else {
                continue
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: documentType
            ]

            if let attributedString = try? NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            ) {
                return attributedString.string
            }
        }

        return nil
    }

    private func documentType(for pasteboardType: NSPasteboard.PasteboardType) -> NSAttributedString.DocumentType? {
        if pasteboardType == .rtf || pasteboardType == publicRTF || pasteboardType == nextRTF {
            return .rtf
        }

        if pasteboardType == .rtfd || pasteboardType == flatRTFD {
            return .rtfd
        }

        if pasteboardType == .html || pasteboardType == publicHTML || pasteboardType == appleHTML {
            return .html
        }

        return nil
    }

    private func updateStatusUI() {
        let statusText = preserveFormatting ? "PurePaste: Bypass On" : "PurePaste: Stripping On"
        statusMenuItem?.title = statusText
        preserveFormattingMenuItem?.state = preserveFormatting ? .on : .off
        statusItem?.button?.toolTip = preserveFormatting
            ? "PurePaste is preserving clipboard formatting"
            : "PurePaste is stripping rich clipboard formatting"
    }

    @objc private func togglePreserveFormatting() {
        preserveFormatting.toggle()
        defaults.set(preserveFormatting, forKey: DefaultsKey.preserveFormatting)
        updateStatusUI()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = ClipboardFormatterStripper()
app.delegate = delegate
app.run()
