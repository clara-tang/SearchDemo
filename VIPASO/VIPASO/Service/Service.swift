import Foundation

public protocol ServiceType {
    func fetch<T: Decodable>(_ url: URL) async -> Result<T, RequestError>
}

final class Service: ServiceType {
    func fetch<T: Decodable>(_ url: URL) async -> Result<T, RequestError> {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let error = parseResponseError(response) {
                return .failure(error)
            }
            
            do {
                let decodedResult: T = try JSONDecoder().decode(T.self, from: data)
                return .success(decodedResult)
            } catch {
                return .failure(RequestError.decodingFailed)
            }
        } catch {
            return .failure(RequestError.badResponse)
        }
    }
    
    private func parseResponseError(_ response: URLResponse) -> RequestError? {
        guard let response = response as? HTTPURLResponse,
              Constants.successCodeRange.contains(response.statusCode) else {
            return .badResponse
        }
        
        switch response.statusCode {
        case let code where Constants.clientErrorCodeRange.contains(code):
            return .clientBadRequest
        case let code where code == Constants.noConnectionCode:
            return .noConnection
        case let code where Constants.serverBadResponseCodeRange.contains(code):
            return .badResponse
        default: return nil
        }
    }
}

private extension Service {
    enum Constants {
        static let successCodeRange: ClosedRange<Int> = 200...299
        static let clientErrorCodeRange: ClosedRange<Int> = 400...499
        static let serverBadResponseCodeRange: ClosedRange<Int> = 500...599
        static let noConnectionCode: Int = 503
    }
}

