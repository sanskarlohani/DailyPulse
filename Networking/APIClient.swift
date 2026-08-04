import Foundation

protocol APIClientProtocol {
    func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw NetworkError.badURL
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badResponse(statusCode: 0)
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingError(error)
                }
            case 401:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
