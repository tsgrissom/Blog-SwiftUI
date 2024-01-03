import SwiftUI
import SwiftData

struct UserAccountAdminView: View {
    
    @Query
    private var comments: [BlogComment]
    @Query
    private var posts: [BlogPost]
    
    private let user: UserAccount
    
    init(_ user: UserAccount) {
        self.user = user
    }
    
    private var textInternalId: some View {
        return Text("Internal ID: \(user.id)")
    }
    
    private var textJoined: some View {
        let createdDate = Date(timeIntervalSince1970: user.createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: createdDate)
        
        return Text("Joined: \(createdFmt)")
    }
    
    private var textCommentsCount: some View {
        let associatedComments = user.getAssociatedComments(allComments: comments)
        return Text("Comments made: \(associatedComments.count)")
    }
    
    private var textPostsCount: some View {
        let associatedPosts = user.getAssociatedPosts(allPosts: posts)
        return Text("Posts made: \(associatedPosts.count)")
    }
    
    private var textUsername: some View {
        return Text("Username: \"\(user.username)\"")
    }
    
    private var textDisplayName: some View {
        return Text("Display Name: \"\(user.displayName)\"")
    }
    
    private var textBiography: some View {
        return Text("Biography: \"\(user.biography)\"")
    }
    
    public var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Fixed")
                        .font(.title2)
                        .bold()
                    textInternalId
                    textJoined
                    
                    Text("Statistics")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    textPostsCount
                    textCommentsCount
                    
                    Text("User-Configured")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    textUsername
                    textDisplayName
                    textBiography
                    
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal, 22)
        }
        .navigationTitle("Admin View: User @\(user.username)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private var mockUser: UserAccount {
    UserAccount(
        username: "Tyler",
        password: "Password"
    )
}

#Preview {
    NavigationStack {
        UserAccountAdminView(mockUser)
    }
}
