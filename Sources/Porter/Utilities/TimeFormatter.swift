import Foundation

enum TimeFormatter {
    static func formatUptime(since date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        guard interval >= 60 else {
            return "< 1m"
        }

        let minutes = Int(interval) / 60
        let hours = minutes / 60
        let days = hours / 24

        if days > 0 {
            let remainingHours = hours % 24
            return "\(days)d \(remainingHours)h"
        } else if hours > 0 {
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
