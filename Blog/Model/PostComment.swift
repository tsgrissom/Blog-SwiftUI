import Foundation
import SwiftData

@Model
final class PostComment: Identifiable {

    var id:   String
    var body: String
    var postedBy: String // UUID of a UserAccount
    
    var attachedTo: String // UUID of a Post
    var parentComment: String? // UUID of another PostComment
    
    var createdAt: Double
    
    init(
        body: String,
        postedBy: UserAccount,
        attachedTo: Post,
        parentComment: PostComment? = nil
    ) {
        self.id = UUID().uuidString
        self.body = body
        self.postedBy = postedBy.id
        self.attachedTo = attachedTo.id
        self.parentComment = parentComment?.id
        self.createdAt = Date().timeIntervalSince1970
    }
    
    public func getChildComments(allComments: [PostComment]) -> [PostComment] {
        return allComments.filter { that in
            that.parentComment == self.id
        }
    }
    
    public func isOwnedBy(_ user: UserAccount?) -> Bool {
        return self.postedBy == user?.id
    }
}
