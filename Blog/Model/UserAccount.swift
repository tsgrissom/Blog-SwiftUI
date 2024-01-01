import Foundation
import SwiftData

@Model
final class UserAccount: Identifiable {
    
    var id: String
    var username: String
    var password: String
    
    var createdAt: Double
    
    init(
        username: String,
        password: String
    ) {
        self.id = UUID().uuidString
        self.username = username
        self.password = password
        self.createdAt = Date().timeIntervalSince1970
    }
}
