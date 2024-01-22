import Foundation
import SwiftData

@Model
final class Post: Identifiable {
    
    var id: String
    var body: String
    var postedBy: String // Id of UserAccount
    
    var createdAt: Double
    
    init(
        body: String,
        postedBy: UserAccount
    ) {
        self.id = UUID().uuidString
        self.body = body
        self.postedBy = postedBy.id
        self.createdAt = Date().timeIntervalSince1970 
    }
    
    public func getAttachedComments(allComments: [PostComment]) -> [PostComment] {
        return allComments.filter { comment in
            comment.attachedTo == self.id
        }
    }
    
    public func isOwnedBy(_ user: UserAccount?) -> Bool {
        return postedBy == user?.id
    }
}
