import Foundation
import SwiftData

@Model
final class Post: Identifiable {
    
    var id: String
    var body: String
    var postedBy: UserAccount
    
    var createdAt: Double
    
    init(
        body: String,
        postedBy: UserAccount
    ) {
        self.id = UUID().uuidString
        self.body = body
        self.postedBy = postedBy
        self.createdAt = Date().timeIntervalSince1970 
    }
    
    public func getAttachedComments(allComments: [PostComment]) -> [PostComment] {
        return allComments.filter { comment in
            comment.attachedTo.id == self.id
        }
    }
}
