import LoremSwiftum
import SwiftUI
import SwiftData

struct CommentView: View {
    
    @Query
    private var comments: [PostComment]
    @Query
    private var posts: [Post]
    @Query
    private var users: [UserAccount]
    
    private let comment: PostComment
    
    init(_ comment: PostComment) {
        self.comment = comment
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 3) {
                    textUsername
                    textCreatedAt
                    Spacer()
                }
                .font(.caption)
                
                textCommentBody
            }
            Spacer()
        }
    }
    
    private var textCommentBody: some View {
        return Text("\"\(comment.body)\"")
    }
    
    private var textCreatedAt: some View {
        let formatter = DateFormatter()
        let createdDate = Date(timeIntervalSince1970: comment.createdAt)
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: createdDate)
        
        return Text("at \(createdFmt)")
    }
    
    private var textUsername: some View {
        let user = users.first {
            $0.id == comment.postedBy
        }
        let username = user?.username ?? "Unknown"
        
        return Text("@\(username)")
            .foregroundStyle(.blue)
    }
}

#Preview {
    func generateViewForMockComment() -> some View {
        let firstName  = LoremSwiftum.Lorem.firstName
        let lastName   = LoremSwiftum.Lorem.lastName
        let tweet      = LoremSwiftum.Lorem.tweet
        
        let mockUser = UserAccount(username: firstName, password: "Password")
        mockUser.displayName = "\(firstName)\(lastName)"
        let mockPost = Post(body: tweet, postedBy: mockUser)
        let mockComment = PostComment(body: "String", postedBy: mockUser, attachedTo: mockPost)
        
        return CommentView(mockComment)
    }
    
    return VStack {
        ForEach(1...10, id: \.self) { _ in
            generateViewForMockComment()
        }
    }
}
