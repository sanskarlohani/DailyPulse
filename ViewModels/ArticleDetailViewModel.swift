import Foundation

@MainActor
final class ArticleDetailViewModel: ObservableObject {
    @Published var article: Article
    @Published var isBookmarked = false
    @Published var relatedArticles: [Article] = []
    @Published var isLoadingRelated = false
    
    private let storageService: StorageServiceProtocol
    private let newsService: NewsServiceProtocol
    
    init(
        article: Article,
        storageService: StorageServiceProtocol,
        newsService: NewsServiceProtocol = NewsAPIService()
    ) {
        self.article = article
        self.storageService = storageService
        self.newsService = newsService
        self.isBookmarked = storageService.isBookmarked(url: article.url)
    }
    
    func trackReadHistory() {
        storageService.addToHistory(article)
    }
    
    func toggleBookmark() {
        storageService.toggleBookmark(article)
        isBookmarked = storageService.isBookmarked(url: article.url)
        article.isBookmarked = isBookmarked
    }
    
    func loadRelatedArticles() async {
        isLoadingRelated = true
        let category = article.category ?? "General"
        
        do {
            let fetched = try await newsService.fetchTopHeadlines(category: category, page: 1)
            // Filter out current article and limit to 4
            self.relatedArticles = Array(fetched.filter { $0.url != article.url }.prefix(4))
        } catch {
            print("Failed to fetch live related articles, using mocks: \(error)")
            // Fallback to mock service
            do {
                let fetchedMock = try await MockNewsService.shared.fetchTopHeadlines(category: category, page: 1)
                self.relatedArticles = Array(fetchedMock.filter { $0.url != article.url }.prefix(4))
            } catch {
                self.relatedArticles = []
            }
        }
        isLoadingRelated = false
    }
}
