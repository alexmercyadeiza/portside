import Foundation
import SwiftUI

@Observable
final class PortListViewModel {
    var processes: [PortProcess] = []
    var isRefreshing = false

    private let scanner = PortScanner()
    private var timer: Timer?

    init() {
        startPolling()
    }

    func startPolling() {
        timer?.invalidate()
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func refresh() {
        Task { @MainActor in
            isRefreshing = true
            let results = await scanner.scan()
            withAnimation(.easeInOut(duration: 0.2)) {
                processes = results
            }
            isRefreshing = false
        }
    }

    func kill(_ process: PortProcess) {
        ProcessManager.kill(pid: process.pid, port: process.port)
        withAnimation(.easeOut(duration: 0.2)) {
            processes.removeAll { $0.id == process.id }
        }
    }

    func open(_ process: PortProcess) {
        ProcessManager.openInBrowser(port: process.port)
    }
}
