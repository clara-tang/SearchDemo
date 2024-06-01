import Foundation

struct Response: Codable {
    let users: [User]
    
    private enum CodingKeys: String, CodingKey {
        case users       = "items"
    }
}

struct User: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let avatorURL: URL?
    
    private enum CodingKeys: String, CodingKey {        
        case id
        case name        = "login"
        case avatorURL   = "avatar_url"
    }
}
