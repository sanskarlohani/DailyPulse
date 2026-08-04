import XCTest
import Combine
@testable import DailyPulse

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var sut: SearchViewModel!
    private var mockService: MockNewsService!
    
    override func setUp() async throws {
        try await super.setUp()
        mockService = MockNewsService.shared
        sut = SearchViewModel(newsService: mockService, mockService: mockService)
        sut.clearRecentSearches() // Ensure starting in clean state
    }
    
    override func tearDown() async throws {
        sut.clearRecentSearches()
        sut = nil
        mockService = nil
        try await super.tearDown()
    }
    
    func testPerformSearch_shouldFetchMatchesAndSaveToRecents() async {
        // Given
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertTrue(sut.recentSearches.isEmpty)
        
        // When: Search for "Apple"
        await sut.performSearch(query: "Apple")
        
        // Then
        XCTAssertFalse(sut.searchResults.isEmpty)
        XCTAssertEqual(sut.recentSearches.first, "Apple")
        XCTAssertNil(sut.errorMessage)
        
        // Verify result content matches filter
        XCTAssertTrue(sut.searchResults.allSatisfy {
            $0.title.localizedCaseInsensitiveContains("Apple") ||
            ($0.articleDescription?.localizedCaseInsensitiveContains("Apple") ?? false)
        })
    }
    
    func testDeleteAndClearRecentSearches_shouldWipeListsCorrectly() async {
        // Given
        await sut.performSearch(query: "Apple")
        await sut.performSearch(query: "Market")
        XCTAssertEqual(sut.recentSearches.count, 2)
        XCTAssertEqual(sut.recentSearches.first, "Market")
        
        // When: Delete "Market" from recent searches
        sut.deleteRecentSearch("Market")
        
        // Then
        XCTAssertEqual(sut.recentSearches.count, 1)
        XCTAssertEqual(sut.recentSearches.first, "Apple")
        
        // When: Clear all searches
        sut.clearRecentSearches()
        
        // Then
        XCTAssertTrue(sut.recentSearches.isEmpty)
    }
}
