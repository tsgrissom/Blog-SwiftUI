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
    // TODO Banning, suspension
    
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
    
    public func getAllPosts(allPosts: [Post]) -> [Post] {
        return allPosts.filter { post in
            post.postedBy == self.id
        }
    }
    
    public func getAllComments(allComments: [PostComment]) -> [PostComment] {
        return allComments.filter { comment in
            comment.postedBy == self.id
        }
    }
    
    public func getRankTitle() -> String {
        return switch self.permissionLevel {
            case 1:  "Subscriber"
            case 2:  "Moderator"
            case 3:  "Operator"
            case 4:  "Superuser"
            default: "Default"
        }
    }
    
    public func isRankSuperiorTo(_ user: UserAccount?) -> Bool {
        let thisLevel = self.permissionLevel
        let thatLevel = user==nil ? 0 : user!.permissionLevel
        
        if thisLevel == 4 {
            return true
        } else if thisLevel == 3 && thatLevel < 4 {
            return false
        }
        
        return thisLevel > thatLevel
    }
    
    public func isRankInferiorTo(_ user: UserAccount?) -> Bool {
        return !self.isRankSuperiorTo(user)
    }
    
    public func isPublicUser() -> Bool {
        return self.permissionLevel <= 1
    }
    
    public func isModerator() -> Bool {
        return self.permissionLevel >= 2
    }
    
    public func isOperator() -> Bool {
        return self.permissionLevel >= 3
    }
    
    public func isSuperUser() -> Bool {
        return self.permissionLevel == 4
    }
}
