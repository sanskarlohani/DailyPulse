import XCTest
@testable import DailyPulse

@MainActor
final class HomeViewModelTests: XCTestCase {
    private var sut: HomeViewModel!
    private var mockService: MockNewsService!
    
    override func setUp() async throws {
        try await super.setUp()
        mockService = MockNewsService.shared
        sut = HomeViewModel(newsService: mockService, mockService: mockService)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockService = nil
        try await super.tearDown()
    }
    
    func testLoadContent_shouldLoadBreakingAndCategoryArticles() async {
        // Given starting state
        XCTAssertTrue(sut.breakingArticles.isEmpty)
        XCTAssertTrue(sut.articles.isEmpty)
        XCTAssertFalse(sut.isLoading)
        
        // When
        await sut.loadContent()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.breakingArticles.isEmpty)
        XCTAssertFalse(sut.articles.isEmpty)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testChangeCategory_shouldTriggerRefreshAndClearArticles() async {
        // Given loaded state
        await sut.loadContent()
        XCTAssertEqual(sut.selectedCategory, "General")
        _ = sut.articles.count
        
        // When: Switching category to Business (triggers refresh)
        sut.selectedCategory = "Business"
        
        // Wait a small moment for async task to run
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        // Then
        XCTAssertEqual(sut.selectedCategory, "Business")
        XCTAssertFalse(sut.articles.isEmpty)
        // Business articles should be subset filtered
        XCTAssertTrue(sut.articles.allSatisfy { $0.category == "Business" })
    }
}
