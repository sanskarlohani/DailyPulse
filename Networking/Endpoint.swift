import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
    
    private static let baseURL = "https://newsapi.org/v2/"
    
    var urlRequest: URLRequest? {
        guard var components = URLComponents(string: Self.baseURL + path) else {
            return nil
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

// MARK: - NewsAPI Endpoints Factory
extension Endpoint {
    /// Get top headlines for a specific category or country
    static func topHeadlines(category: String?, country: String = "us", page: Int = 1, apiKey: String) -> Endpoint {
        var items = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: "20"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        if let category = category, category.lowercased() != "general" {
            items.append(URLQueryItem(name: "category", value: category.lowercased()))
        }
        
        return Endpoint(path: "top-headlines", queryItems: items)
    }
    
    /// Search for articles using a text query
    static func search(query: String, page: Int = 1, apiKey: String) -> Endpoint {
        let items = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: "20"),
            URLQueryItem(name: "sortBy", value: "publishedAt"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        return Endpoint(path: "everything", queryItems: items)
    }
    
    /// Get breaking/trending news
    static func breakingNews(apiKey: String) -> Endpoint {
        let items = [
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "pageSize", value: "5"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        // Swapped to standard queries for top-headlines
        var topItems = items
        topItems.append(URLQueryItem(name: "country", value: "us"))
        return Endpoint(path: "top-headlines", queryItems: topItems)
    }
}
