import Foundation
import SwiftData

@Model
final class BlogPost: Identifiable {
    
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
    
    public func getChildComments(allComments: [BlogComment]) -> [BlogComment] {
        return allComments.filter { comment in
            comment.attachedTo.id == self.id
        }
    }
}
