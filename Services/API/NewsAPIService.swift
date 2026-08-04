import Foundation

protocol NewsServiceProtocol {
    func fetchTopHeadlines(category: String?, page: Int) async throws -> [Article]
    func searchArticles(query: String, page: Int) async throws -> [Article]
    func fetchBreakingNews() async throws -> [Article]
}

final class NewsAPIService: NewsServiceProtocol {
    private let client: APIClientProtocol
    
    // Fallback/demo API Key to allow testing out-of-the-box.
    // Recommended to change this in SettingsView.
    private var apiKey: String {
        let savedKey = UserDefaults.standard.string(forKey: "news_api_key") ?? ""
        return savedKey.isEmpty ? "4855224cd55045809fe8c8d7d2e603c6" : savedKey // Sample key
    }
    
    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }
    
    func fetchTopHeadlines(category: String?, page: Int = 1) async throws -> [Article] {
        let endpoint = Endpoint.topHeadlines(category: category, page: page, apiKey: apiKey)
        let response: NewsAPIResponse = try await client.execute(endpoint)
        return parseResponse(response, category: category)
    }
    
    func searchArticles(query: String, page: Int = 1) async throws -> [Article] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        let endpoint = Endpoint.search(query: query, page: page, apiKey: apiKey)
        let response: NewsAPIResponse = try await client.execute(endpoint)
        return parseResponse(response)
    }
    
    func fetchBreakingNews() async throws -> [Article] {
        let endpoint = Endpoint.breakingNews(apiKey: apiKey)
        let response: NewsAPIResponse = try await client.execute(endpoint)
        return parseResponse(response, category: "Breaking")
    }
    
    private func parseResponse(_ response: NewsAPIResponse, category: String? = nil) -> [Article] {
        guard let apiArticles = response.articles else { return [] }
        return apiArticles.compactMap { $0.toArticle(category: category) }
    }
}
