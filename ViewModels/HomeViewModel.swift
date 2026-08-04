import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // Categories according to specification
    let categories = ["General", "Business", "Technology", "Sports", "Entertainment", "Science", "Health", "Politics"]
    
    @Published var selectedCategory = "General" {
        didSet {
            Task {
                await refreshArticles()
            }
        }
    }
    
    @Published var breakingArticles: [Article] = []
    @Published var articles: [Article] = []
    
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var isOfflineMode = false
    
    private var currentPage = 1
    private var hasMore = true
    
    private let newsService: NewsServiceProtocol
    private let mockService: NewsServiceProtocol
    
    init(newsService: NewsServiceProtocol = NewsAPIService(), mockService: NewsServiceProtocol = MockNewsService.shared) {
        self.newsService = newsService
        self.mockService = mockService
    }
    
    /// Loads initial data (Breaking News + Selected Category Headlines)
    func loadContent() async {
        isLoading = true
        errorMessage = nil
        isOfflineMode = false
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchBreakingNews() }
            group.addTask { await self.fetchArticles(isRefresh: true) }
        }
        
        isLoading = false
    }
    
    /// Pull to refresh handler
    func refreshArticles() async {
        errorMessage = nil
        await fetchArticles(isRefresh: true)
    }
    
    /// Fetches the headline carousel
    private func fetchBreakingNews() async {
        do {
            self.breakingArticles = try await newsService.fetchBreakingNews()
        } catch {
            print("Live breaking news failed, falling back to mocks: \(error.localizedDescription)")
            do {
                self.breakingArticles = try await mockService.fetchBreakingNews()
            } catch {
                self.errorMessage = "Failed to load breaking news: \(error.localizedDescription)"
            }
        }
    }
    
    /// Fetches category articles with pagination support
    func fetchArticles(isRefresh: Bool = false) async {
        if isRefresh {
            currentPage = 1
            hasMore = true
        }
        
        guard !isLoadingMore && (isRefresh || hasMore) else { return }
        
        if isRefresh {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        do {
            let fetched = try await newsService.fetchTopHeadlines(category: selectedCategory, page: currentPage)
            
            if isRefresh {
                self.articles = fetched
            } else {
                self.articles.append(contentsOf: fetched)
            }
            
            if fetched.count < 20 {
                hasMore = false
            } else {
                currentPage += 1
            }
            isOfflineMode = false
        } catch {
            print("Live category articles failed, falling back to mocks: \(error.localizedDescription)")
            isOfflineMode = true
            do {
                let fetchedMock = try await mockService.fetchTopHeadlines(category: selectedCategory, page: currentPage)
                if isRefresh {
                    self.articles = fetchedMock
                } else {
                    self.articles.append(contentsOf: fetchedMock)
                }
                hasMore = false // Mocks are static and not paginated
            } catch {
                self.errorMessage = "Failed to load articles: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
        isLoadingMore = false
    }
}
