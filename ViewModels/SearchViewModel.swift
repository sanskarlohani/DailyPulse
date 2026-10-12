import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [Article] = []
    @Published var recentSearches: [String] = []
    
    let trendingSearches = ["Spatial Computing", "AI Chips", "Inflation Rate", "James Webb", "Climate Accord"]
    
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private var hasMore = true
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    private let newsService: NewsServiceProtocol
    private let mockService: NewsServiceProtocol
    private let recentSearchesKey = "recent_searches"
    
    init(newsService: NewsServiceProtocol = NewsAPIService(), mockService: NewsServiceProtocol = MockNewsService.shared) {
        self.newsService = newsService
        self.mockService = mockService
        
        loadRecentSearches()
        setupDebouncedSearch()
    }
    
    private func setupDebouncedSearch() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                // Cancel previous running search task to prevent race conditions
                self.searchTask?.cancel()
                self.searchTask = Task { [weak self] in
                    guard let self = self else { return }
                    if query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 {
                        await self.performSearch(query: query)
                    } else if query.isEmpty {
                        self.searchResults = []
                        self.errorMessage = nil
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// Executes the query and saves it to recent searches
    func performSearch(query: String, isRefresh: Bool = true) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        if isRefresh {
            currentPage = 1
            hasMore = true
            isLoading = true
        } else {
            guard hasMore && !isLoadingMore else { return }
            isLoadingMore = true
        }
        
        errorMessage = nil
        
        // Add to recents
        saveRecentSearch(trimmedQuery)
        
        do {
            let fetched = try await newsService.searchArticles(query: trimmedQuery, page: currentPage)
            guard !Task.isCancelled else { return }
            
            if isRefresh {
                self.searchResults = fetched
            } else {
                self.searchResults.append(contentsOf: fetched)
            }
            
            if fetched.count < 20 {
                hasMore = false
            } else {
                currentPage += 1
            }
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            print("Live search failed, trying mock: \(error.localizedDescription)")
            do {
                let fetchedMock = try await mockService.searchArticles(query: trimmedQuery, page: currentPage)
                guard !Task.isCancelled else { return }
                
                if isRefresh {
                    self.searchResults = fetchedMock
                } else {
                    self.searchResults.append(contentsOf: fetchedMock)
                }
                hasMore = false
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = "Failed to fetch search results: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
        isLoadingMore = false
    }
    
    func deleteRecentSearch(_ search: String) {
        recentSearches.removeAll { $0.lowercased() == search.lowercased() }
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
    
    private func saveRecentSearch(_ search: String) {
        var current = recentSearches
        current.removeAll { $0.lowercased() == search.lowercased() }
        current.insert(search, at: 0)
        
        // Limit to 8 recent searches
        if current.count > 8 {
            current = Array(current.prefix(8))
        }
        
        recentSearches = current
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    private func loadRecentSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: recentSearchesKey) {
            recentSearches = saved
        }
    }
}
