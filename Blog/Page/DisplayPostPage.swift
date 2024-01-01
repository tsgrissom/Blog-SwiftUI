import SwiftUI

struct DisplayPostPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Environment(\.dismiss)
    private var dismiss
    
    private let post: BlogPost
    
    init(_ post: BlogPost) {
        self.post = post
    }
    
    private var isSelfOwned: Bool {
        accountManager.loggedInUser?.id == post.postedBy.id
    }
    
    private func onPressReplyButton() {
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            sectionPostBody
                .padding(.top, 8)
            rowPostedBy
                .padding(.top, 4)
            sectionUserDependentControls
                .padding(.top)
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("Post by @\(post.postedBy.username)")
    }
    
    private var rowPostedBy: some View {
        let username = post.postedBy.username
        let formatter = DateFormatter()
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
//      formatter.dateFormat = "MMMM dd'th', yyyy 'at' h:mm a"  // Old
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"     // American
//      formatter.dateFormat = "yyyy'-'MM'-'dd 'at' h:mm a" // International
        let createdFmt = formatter.string(from: createdDate)
        
        return HStack(spacing: 3) {
            NavigationLink(destination: Text("View for user @\(username)")) {
                HStack(spacing: 3) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 20, height: 20)
                    Text("@\(username)")
                        .foregroundStyle(.blue)
                }
            }
            Text("at \(createdFmt)")
            Spacer()
        }
        .font(.caption)
    }
    
    private var sectionPostBody: some View {
        HStack {
            Text(post.body)
            Spacer()
        }
    }
    
    private var buttonReply: some View {
        let bgColor = accountManager.isLoggedIn ? Color.blue : Color.gray
        return Button(action: onPressReplyButton) {
            Text("Reply")
        }
        .tint(bgColor)
    }
    
    private var buttonEdit: some View {
        return Button(action: {}) {
            Text("Edit")
        }
        .tint(.blue)
    }
    
    private var buttonDelete: some View {
        return Button(action: {}) {
            Text("Delete")
        }
        .tint(.red)
    }
    
    private var buttonShare: some View {
        return Button(action: {}) {
            Image(systemName: "square.and.arrow.up")
        }
        .tint(.secondary)
    }
    
    private var sectionUserDependentControls: some View {
        HStack {
            if isSelfOwned {
                buttonEdit
            }
            
            buttonReply
            
            if isSelfOwned {
                buttonDelete
            }
            
            buttonShare
            
            Spacer()
        }
        .buttonStyle(.bordered)
    }
}

//#Preview {
//    let user = UserAccount(username: "Tyler", password: "Password")
//    let mockPost = BlogPost(body: "Lorem ipsum dolor this is my fake blog post", postedBy: user)
//    return DisplayPostPage(mockPost)
//        .environmentObject(UserAccountManager())
//}
