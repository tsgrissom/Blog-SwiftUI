import Combine
import Foundation
import SwiftUI
import SwiftData

final class PostManager: ObservableObject {
    
    public func getPostsForUser(_ user: UserAccount, allPosts: [Post]) -> [Post] {
        return allPosts.filter { post in
            post.postedBy == user.id
        }
    }
    
    public func getCommentsInResponseToPost(_ post: Post, allComments: [PostComment]) -> [PostComment] {
        return allComments.filter { comment in
            comment.attachedTo == post.id
        }
    }
}
