import Foundation

struct PortProcess: Identifiable, Hashable {
    let pid: Int32
    let port: UInt16
    let command: String
    let projectName: String
    let workingDirectory: String
    let gitBranch: String?
    let startTime: Date?

    var id: String { "\(pid)-\(port)" }

    var uptimeString: String {
        guard let startTime else { return "—" }
        return TimeFormatter.formatUptime(since: startTime)
    }

    var localURL: URL? {
        URL(string: "http://localhost:\(port)")
    }
}
