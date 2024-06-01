
public enum RequestError: Error {
    case invalidURL
    case decodingFailed
    case clientBadRequest
    case badResponse
    case noConnection
}
