import Combine
import Foundation
import SwiftUI
import SwiftData

final class PostManager: ObservableObject {
    
    public func getPostsForUser(_ user: UserAccount, allPosts: [BlogPost]) -> [BlogPost] {
        return allPosts.filter { post in
            post.postedBy.id == user.id
        }
    }
    
    public func getCommentsInResponseToPost(_ post: BlogPost, allComments: [BlogComment]) -> [BlogComment] {
        return allComments.filter { comment in
            comment.attachedTo.id == post.id
        }
    }
}
