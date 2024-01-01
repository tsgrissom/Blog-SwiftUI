import Foundation
import SwiftData

@Model
final class BlogComment: Identifiable {

    var id:   String
    var body: String
    var postedBy: UserAccount
    
    var attachedTo: BlogPost
    var parentComment: BlogComment?
    
    var createdAt: Double
    
    init(
        body: String,
        postedBy: UserAccount,
        attachedTo: BlogPost,
        parentComment: BlogComment? = nil
    ) {
        self.id = UUID().uuidString
        self.body = body
        self.postedBy = postedBy
        self.attachedTo = attachedTo
        self.parentComment = parentComment
        self.createdAt = Date().timeIntervalSince1970
    }
}
