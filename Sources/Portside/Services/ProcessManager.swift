import AppKit
import Foundation

enum ProcessManager {
    /// Kill a process after verifying it still owns the expected port.
    /// Prevents PID-reuse race conditions.
    static func kill(pid: Int32, port: UInt16) {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = ["-p", "\(pid)", "-iTCP:\(port)", "-sTCP:LISTEN", "-t"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        guard (try? process.run()) != nil else { return }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        let output = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Only kill if the PID still owns that port
        guard output == "\(pid)" else { return }
        Foundation.kill(pid, SIGTERM)
    }

    static func openInBrowser(port: UInt16) {
        guard let url = URL(string: "http://localhost:\(port)") else { return }
        NSWorkspace.shared.open(url)
    }
}
