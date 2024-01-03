import Foundation
import SwiftData

@Model
final class UserAccount: Identifiable {
    
    /*
     * User Permission Levels
     * 0 - Default
     * 1 - Subscriber
     * 2 - Moderator
     * 3 - Operator
     * 4 - Superuser
     */
    
    var id: String
    var createdAt: Double
    
    var username: String
    var password: String
    var permissionLevel: Int
    
    var displayName: String
    var biography: String
    
    init(
        username: String,
        password: String,
        biography: String = "",
        permissionLevel: Int = 0
    ) {
        self.id              = UUID().uuidString
        self.createdAt       = Date().timeIntervalSince1970
        self.username        = username
        self.displayName     = username
        self.password        = password
        self.biography       = biography
        self.permissionLevel = permissionLevel
    }
    
    public func getAssociatedPosts(allPosts: [BlogPost]) -> [BlogPost] {
        return allPosts.filter { post in
            post.postedBy.id == self.id
        }
    }
    
    public func getAssociatedComments(allComments: [BlogComment]) -> [BlogComment] {
        return allComments.filter { comment in
            comment.postedBy.id == self.id
        }
    }
    
    public func isRankSuperiorTo(_ user: UserAccount) -> Bool {
        let thisLevel = self.permissionLevel
        let thatLevel = user.permissionLevel
        
        if thisLevel == 4 {
            return true
        } else if thisLevel == 3 && thatLevel < 4 {
            return false
        }
        
        return thisLevel > thatLevel
    }
}
