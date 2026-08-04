import Foundation

enum NetworkError: LocalizedError {
    case badURL
    case badResponse(statusCode: Int)
    case noData
    case decodingError(Error)
    case requestFailed(Error)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "The request URL is invalid."
        case .badResponse(let statusCode):
            return "The server responded with an error code: \(statusCode)."
        case .noData:
            return "No data was returned from the server."
        case .decodingError(let error):
            return "Failed to parse the server response: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "Network connection failed: \(error.localizedDescription)"
        case .unauthorized:
            return "Invalid API key. Please check your settings."
        }
    }
}
