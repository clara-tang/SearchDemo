@testable import VIPASO
import Foundation

final class MockService: ServiceType {
    private var response: Decodable?
    private var error: RequestError?

    init(response: Decodable? = nil, error: RequestError? = nil) {
        self.response = response
        self.error = error
    }

    func fetch<T: Decodable>(_ url: URL) async -> Result<T, RequestError> {
        if let error {
            return .failure(error)
        }
        
        guard let data = response as? T else {
            return .failure(.decodingFailed)
        }
        
        return .success(data)
    }
}
