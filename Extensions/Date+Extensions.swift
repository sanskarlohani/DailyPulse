import Foundation

extension Date {
    /// Formats the date to a relative string (e.g., "3 hours ago", "Yesterday")
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let week = components.weekOfYear, week > 0 {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
        
        if let day = components.day, day > 0 {
            if day == 1 {
                return "Yesterday"
            }
            return "\(day) days ago"
        }
        
        if let hour = components.hour, hour > 0 {
            return "\(hour) \(hour == 1 ? "hour" : "hours") ago"
        }
        
        if let minute = components.minute, minute > 0 {
            return "\(minute) \(minute == 1 ? "minute" : "minutes") ago"
        }
        
        return "Just now"
    }
}

extension String {
    /// Parses ISO8601 date string to Date object
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: self) {
            return date
        }
        
        // Fallback for missing fractional seconds or timezone variations
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = fallbackFormatter.date(from: self) {
            return date
        }
        
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return fallbackFormatter.date(from: self)
    }
    
    /// Helper to format date string directly
    func formattedTimeAgo() -> String {
        guard let date = self.toDate() else { return self }
        return date.timeAgo()
    }
}
