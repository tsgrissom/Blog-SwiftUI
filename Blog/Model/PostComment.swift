import Foundation
import SwiftData

@Model
final class PostComment: Identifiable {

    var id:   String
    var body: String
    var postedBy: UserAccount
    
    var attachedTo: Post
    var parentComment: PostComment?
    
    var createdAt: Double
    
    init(
        body: String,
        postedBy: UserAccount,
        attachedTo: Post,
        parentComment: PostComment? = nil
    ) {
        self.id = UUID().uuidString
        self.body = body
        self.postedBy = postedBy
        self.attachedTo = attachedTo
        self.parentComment = parentComment
        self.createdAt = Date().timeIntervalSince1970
    }
    
    public func getChildComments(allComments: [PostComment]) -> [PostComment] {
        return allComments.filter { that in
            that.parentComment?.id == self.id
        }
    }
}
