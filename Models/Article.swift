import Foundation
import SwiftData

// MARK: - SwiftData Persistence Model
@Model
final class Article: Identifiable, Hashable {
    @Attribute(.unique) var url: String
    var title: String
    var articleDescription: String?
    var urlToImage: String?
    var publishedAt: String
    var content: String?
    var author: String?
    var sourceName: String
    var category: String?
    
    // User metadata
    var isBookmarked: Bool = false
    var viewedAt: Date? // Non-nil if in reading history
    
    init(
        url: String,
        title: String,
        articleDescription: String? = nil,
        urlToImage: String? = nil,
        publishedAt: String,
        content: String? = nil,
        author: String? = nil,
        sourceName: String,
        category: String? = nil,
        isBookmarked: Bool = false,
        viewedAt: Date? = nil
    ) {
        self.url = url
        self.title = title
        self.articleDescription = articleDescription
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
        self.author = author
        self.sourceName = sourceName
        self.category = category
        self.isBookmarked = isBookmarked
        self.viewedAt = viewedAt
    }
    
    // Convenient calculated property for read time (average 200 words per minute)
    var readTimeInMinutes: Int {
        let text = (title + (articleDescription ?? "") + (content ?? ""))
        let wordCount = text.split(separator: " ").count
        let minutes = Int(ceil(Double(wordCount) / 200.0))
        return max(1, minutes)
    }
    
    // Hashable conformity
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

// MARK: - API / Network DTO (Data Transfer Object)
struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int?
    let articles: [APIArticle]?
}

struct APIArticle: Decodable, Hashable {
    let source: APISource?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    struct APISource: Decodable, Hashable {
        let id: String?
        let name: String?
    }
    
    // Convert to core database model
    func toArticle(category: String? = nil) -> Article? {
        guard let url = url, let title = title, !url.isEmpty, !title.isEmpty else {
            return nil
        }
        return Article(
            url: url,
            title: title,
            articleDescription: description,
            urlToImage: urlToImage,
            publishedAt: publishedAt ?? ISO8601DateFormatter().string(from: Date()),
            content: content,
            author: author,
            sourceName: source?.name ?? "Unknown",
            category: category
        )
    }
}
