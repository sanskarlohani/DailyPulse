import Foundation
import SwiftData

@MainActor
protocol StorageServiceProtocol {
    func toggleBookmark(_ article: Article)
    func isBookmarked(url: String) -> Bool
    func fetchBookmarks() -> [Article]
    func addToHistory(_ article: Article)
    func fetchHistory() -> [Article]
    func clearHistory()
}

@MainActor
final class StorageService: StorageServiceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func toggleBookmark(_ article: Article) {
        let url = article.url
        let descriptor = FetchDescriptor<Article>(predicate: #Predicate<Article> { $0.url == url })
        
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.isBookmarked.toggle()
                if !existing.isBookmarked && existing.viewedAt == nil {
                    context.delete(existing)
                }
            } else {
                article.isBookmarked = true
                context.insert(article)
            }
            try context.save()
        } catch {
            print("Failed to toggle bookmark: \(error.localizedDescription)")
        }
    }
    
    func isBookmarked(url: String) -> Bool {
        let descriptor = FetchDescriptor<Article>(predicate: #Predicate<Article> { $0.url == url })
        do {
            if let existing = try context.fetch(descriptor).first {
                return existing.isBookmarked
            }
        } catch {
            print("Error checking bookmark status: \(error)")
        }
        return false
    }
    
    func fetchBookmarks() -> [Article] {
        let descriptor = FetchDescriptor<Article>(
            predicate: #Predicate<Article> { $0.isBookmarked == true },
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch bookmarks: \(error.localizedDescription)")
            return []
        }
    }
    
    func addToHistory(_ article: Article) {
        let url = article.url
        let descriptor = FetchDescriptor<Article>(predicate: #Predicate<Article> { $0.url == url })
        
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.viewedAt = Date()
            } else {
                article.viewedAt = Date()
                context.insert(article)
            }
            try context.save()
        } catch {
            print("Failed to save view history: \(error.localizedDescription)")
        }
    }
    
    func fetchHistory() -> [Article] {
        let descriptor = FetchDescriptor<Article>(
            predicate: #Predicate<Article> { $0.viewedAt != nil },
            sortBy: [SortDescriptor(\.viewedAt, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch reading history: \(error.localizedDescription)")
            return []
        }
    }
    
    func clearHistory() {
        let descriptor = FetchDescriptor<Article>(predicate: #Predicate<Article> { $0.viewedAt != nil })
        do {
            let historyArticles = try context.fetch(descriptor)
            for article in historyArticles {
                if article.isBookmarked {
                    article.viewedAt = nil // Keep bookmark but remove from history
                } else {
                    context.delete(article) // Safe to delete since it's not bookmarked
                }
            }
            try context.save()
        } catch {
            print("Failed to clear reading history: \(error)")
        }
    }
}
