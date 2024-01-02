import Foundation
import SwiftData

@Model
final class UserAccount: Identifiable {
    
    var id:          String
    var username:    String
    var password:    String
    var displayName: String
    var biography: String
    
    var createdAt: Double
    
    init(
        username: String,
        password: String,
        biography: String = ""
    ) {
        self.id          = UUID().uuidString
        self.username    = username
        self.password    = password
        self.displayName = username
        self.biography   = biography
        self.createdAt   = Date().timeIntervalSince1970
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
}
