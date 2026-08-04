import XCTest
import SwiftData
@testable import DailyPulse

@MainActor
final class StorageServiceTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var sut: StorageService! // System Under Test
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Setup an in-memory container for isolated testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Article.self, configurations: config)
        context = container.mainContext
        sut = StorageService(context: context)
    }
    
    override func tearDown() async throws {
        sut = nil
        context = nil
        container = nil
        try await super.tearDown()
    }
    
    func testToggleBookmark_shouldSaveAndRetrieveCorrectly() {
        // Given
        let article = Article(
            url: "https://example.com/test-article",
            title: "Test Title",
            publishedAt: "2026-08-04T12:00:00Z",
            sourceName: "Test Source"
        )
        
        // When: Toggle bookmark to save it
        sut.toggleBookmark(article)
        
        // Then
        XCTAssertTrue(sut.isBookmarked(url: article.url))
        let bookmarks = sut.fetchBookmarks()
        XCTAssertEqual(bookmarks.count, 1)
        XCTAssertEqual(bookmarks.first?.url, article.url)
        
        // When: Toggle again to remove it
        sut.toggleBookmark(article)
        
        // Then
        XCTAssertFalse(sut.isBookmarked(url: article.url))
        XCTAssertTrue(sut.fetchBookmarks().isEmpty)
    }
    
    func testAddToHistory_shouldTrackViewingDate() {
        // Given
        let article = Article(
            url: "https://example.com/history-article",
            title: "History Title",
            publishedAt: "2026-08-04T12:00:00Z",
            sourceName: "Test Source"
        )
        
        // When: Add to read history
        sut.addToHistory(article)
        
        // Then
        let history = sut.fetchHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertNotNil(history.first?.viewedAt)
        XCTAssertEqual(history.first?.url, article.url)
    }
    
    func testClearHistory_shouldDeleteNonBookmarkedAndRetainBookmarked() {
        // Given: Create a bookmarked article and a read-only history article
        let bookmarked = Article(
            url: "https://example.com/saved",
            title: "Saved Article",
            publishedAt: "2026-08-04T12:00:00Z",
            sourceName: "Source"
        )
        let onlyRead = Article(
            url: "https://example.com/read",
            title: "Only Read Article",
            publishedAt: "2026-08-04T12:00:00Z",
            sourceName: "Source"
        )
        
        // Make 'bookmarked' both saved and read
        sut.toggleBookmark(bookmarked)
        sut.addToHistory(bookmarked)
        
        // Make 'onlyRead' just read
        sut.addToHistory(onlyRead)
        
        XCTAssertEqual(sut.fetchHistory().count, 2)
        XCTAssertEqual(sut.fetchBookmarks().count, 1)
        
        // When: Clear history
        sut.clearHistory()
        
        // Then: History should only contain the bookmarked article (with history view timestamp reset to nil)
        let finalHistory = sut.fetchHistory()
        XCTAssertTrue(finalHistory.isEmpty)
        
        // Bookmarked list should still have the saved article
        let finalBookmarks = sut.fetchBookmarks()
        XCTAssertEqual(finalBookmarks.count, 1)
        XCTAssertEqual(finalBookmarks.first?.url, bookmarked.url)
    }
}
