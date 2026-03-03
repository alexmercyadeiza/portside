import SwiftUI

@main
struct PortsideApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let viewModel = PortListViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let iconConfig = NSImage.SymbolConfiguration(pointSize: 15, weight: .medium)
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Portside")?
                .withSymbolConfiguration(iconConfig)
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: ContentView(viewModel: viewModel)
        )

        observeProcessCount()
    }

    // MARK: - Click handling

    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent, let button = statusItem.button else { return }

        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(
                withTitle: "Quit Portside",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            )
            statusItem.menu = menu
            button.performClick(nil)
            DispatchQueue.main.async { [weak self] in
                self?.statusItem.menu = nil
            }
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    // MARK: - Badge

    private func updateBadge() {
        guard let button = statusItem.button else { return }
        let count = viewModel.processes.count

        let iconConfig = NSImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Portside")?
            .withSymbolConfiguration(iconConfig)

        if count > 0 {
            button.imagePosition = .imageLeading
            button.title = " \(count)"
            if let desc = NSFont.systemFont(ofSize: 11, weight: .bold)
                .fontDescriptor.withDesign(.rounded) {
                button.font = NSFont(descriptor: desc, size: 11)
            }
        } else {
            button.imagePosition = .imageOnly
            button.title = ""
        }
    }

    private func observeProcessCount() {
        withObservationTracking {
            _ = viewModel.processes.count
        } onChange: {
            Task { @MainActor [weak self] in
                self?.updateBadge()
                self?.observeProcessCount()
            }
        }
    }
}
