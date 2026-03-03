import Foundation

actor PortScanner {
    private let excludedCommands: Set<String> = [
        "rapportd", "sharingd", "AirPlayXPCSe", "ControlCente",
        "WiFiAgent", "UserEventAge", "SystemUIServ", "loginwindow",
        "bluetoothd", "mDNSResponde"
    ]

    func scan() async -> [PortProcess] {
        guard let raw = try? await ShellCommand.run(
            executable: "/usr/sbin/lsof",
            arguments: ["-iTCP", "-P", "-n", "-l", "-sTCP:LISTEN", "-F", "pcn"]
        ) else {
            return []
        }

        let entries = parseLsofOutput(raw)
        let filtered = entries.filter { entry in
            entry.port >= 1024 && !excludedCommands.contains(entry.command)
        }

        return await enrichAll(filtered)
    }

    private struct RawEntry: Hashable {
        let pid: Int32
        let command: String
        let port: UInt16
    }

    private func parseLsofOutput(_ output: String) -> [RawEntry] {
        var entries: [RawEntry] = []
        var currentPID: Int32?
        var currentCommand: String?
        var seen: Set<String> = []

        for line in output.split(separator: "\n") {
            let value = String(line.dropFirst())

            switch line.first {
            case "p":
                currentPID = Int32(value)
                currentCommand = nil
            case "c":
                currentCommand = value
            case "n":
                guard let pid = currentPID, let cmd = currentCommand else { continue }
                if let colonIdx = value.lastIndex(of: ":") {
                    let portStr = value[value.index(after: colonIdx)...]
                    if let port = UInt16(portStr) {
                        let key = "\(pid)-\(port)"
                        if !seen.contains(key) {
                            seen.insert(key)
                            entries.append(RawEntry(pid: pid, command: cmd, port: port))
                        }
                    }
                }
            default:
                break
            }
        }

        return entries
    }

    private func enrichAll(_ entries: [RawEntry]) async -> [PortProcess] {
        await withTaskGroup(of: PortProcess?.self) { group in
            for entry in entries {
                group.addTask {
                    await self.enrich(entry)
                }
            }

            var results: [PortProcess] = []
            for await result in group {
                if let result { results.append(result) }
            }
            return results.sorted { $0.port < $1.port }
        }
    }

    private func enrich(_ entry: RawEntry) async -> PortProcess? {
        let workDir = await getWorkingDirectory(pid: entry.pid)
        let projectName = workDir.map { URL(fileURLWithPath: $0).lastPathComponent } ?? entry.command
        var branch: String?
        if let workDir {
            branch = await getGitBranch(directory: workDir)
        }
        let startTime = await getStartTime(pid: entry.pid)

        return PortProcess(
            pid: entry.pid,
            port: entry.port,
            command: entry.command,
            projectName: projectName,
            workingDirectory: workDir ?? "",
            gitBranch: branch,
            startTime: startTime
        )
    }

    private func getWorkingDirectory(pid: Int32) async -> String? {
        guard let output = try? await ShellCommand.run(
            executable: "/usr/sbin/lsof",
            arguments: ["-p", "\(pid)", "-a", "-d", "cwd", "-Fn"]
        ) else {
            return nil
        }
        for line in output.split(separator: "\n") where line.hasPrefix("n") {
            let path = String(line.dropFirst())
            if path != "/" { return path }
        }
        return nil
    }

    private func getGitBranch(directory: String) async -> String? {
        guard let branch = try? await ShellCommand.run(
            executable: "/usr/bin/git",
            arguments: ["-C", directory, "rev-parse", "--abbrev-ref", "HEAD"]
        ), !branch.isEmpty else {
            return nil
        }
        return branch
    }

    private func getStartTime(pid: Int32) async -> Date? {
        guard let raw = try? await ShellCommand.run(
            executable: "/bin/ps",
            arguments: ["-p", "\(pid)", "-o", "lstart="]
        ), !raw.isEmpty else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM  d HH:mm:ss yyyy"

        if let date = formatter.date(from: raw) {
            return date
        }
        formatter.dateFormat = "EEE MMM d HH:mm:ss yyyy"
        return formatter.date(from: raw)
    }
}
