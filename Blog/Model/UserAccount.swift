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
    
    public func getPermissionLevel() -> PermissionLevel {
        return PermissionLevel.valueOf(self.permissionLevel)
    }
    
    public func isRankedSuperiorTo(_ user: UserAccount?) -> Bool {
        let thisLevel = self.getPermissionLevel()
        let thatPermissionLevel = user==nil ? 0 : user!.permissionLevel
        let thatLevel = PermissionLevel.valueOf(thatPermissionLevel)
        
        return thisLevel.isSuperiorTo(thatLevel)
    }
    
    public func isRankedInferiorTo(_ user: UserAccount?) -> Bool {
        return !self.isRankedSuperiorTo(user)
    }
}
