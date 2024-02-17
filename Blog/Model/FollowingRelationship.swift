import Foundation
import SwiftData

@Model
final class FollowingRelationship: Identifiable {
    
    var id: String
    var followingUser: String
    var followedUser: String
    var createdAt: Double
    
    init(from followingUser: UserAccount, to followedUser: UserAccount) {
        self.id = UUID().uuidString
        self.followingUser = followingUser.id
        self.followedUser = followedUser.id
        self.createdAt = Date().timeIntervalSince1970
    }
}
