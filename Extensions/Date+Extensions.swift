import Foundation

private enum CachedDateFormatters {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let fractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    /// Formats the date to a relative string (e.g., "3 hours ago", "Yesterday")
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let week = components.weekOfYear, week > 0 {
            return CachedDateFormatters.mediumDate.string(from: self)
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
    /// Parses ISO8601 date string to Date object using cached formatters
    func toDate() -> Date? {
        if let date = CachedDateFormatters.iso8601.date(from: self) {
            return date
        }
        
        // Fallback for missing fractional seconds or timezone variations
        if let date = CachedDateFormatters.standard.date(from: self) {
            return date
        }
        
        return CachedDateFormatters.fractionalSeconds.date(from: self)
    }
    
    /// Helper to format date string directly
    func formattedTimeAgo() -> String {
        guard let date = self.toDate() else { return self }
        return date.timeAgo()
    }
}
