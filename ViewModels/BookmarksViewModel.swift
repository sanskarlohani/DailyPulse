import Foundation
import Combine

@MainActor
final class BookmarksViewModel: ObservableObject {
    @Published var bookmarkedArticles: [Article] = []
    @Published var searchQuery = ""
    
    @Published var filteredArticles: [Article] = []
    
    private let storageService: StorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
        
        setupSearchFiltering()
    }
    
    func loadBookmarks() {
        bookmarkedArticles = storageService.fetchBookmarks()
        filterArticles()
    }
    
    private func setupSearchFiltering() {
        $searchQuery
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterArticles()
            }
            .store(in: &cancellables)
    }
    
    func deleteBookmark(at indexSet: IndexSet) {
        for index in indexSet {
            let article = filteredArticles[index]
            storageService.toggleBookmark(article)
        }
        loadBookmarks()
    }
    
    func removeBookmark(_ article: Article) {
        storageService.toggleBookmark(article)
        loadBookmarks()
    }
    
    private func filterArticles() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            filteredArticles = bookmarkedArticles
        } else {
            filteredArticles = bookmarkedArticles.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                ($0.articleDescription?.localizedCaseInsensitiveContains(query) ?? false) ||
                $0.sourceName.localizedCaseInsensitiveContains(query)
            }
        }
    }
}
