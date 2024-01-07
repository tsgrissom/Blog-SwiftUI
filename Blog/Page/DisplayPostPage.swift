import SwiftUI
import SwiftData

struct DisplayPostPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    @EnvironmentObject
    private var postManager: PostManager
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    
    @Query
    private var posts: [Post]
    @Query
    private var comments: [PostComment]
    @Query
    private var users: [UserAccount]
    
    private let post: Post
    
    init(_ post: Post) {
        self.post = post
    }
    
    @State
    private var fieldReplyContents = ""
    @FocusState
    private var isFieldReplyFocused: Bool
    // 0=default,1=error,2=success
    @State
    private var buttonSubmitReplyAnimate = 0
    
    private var getCommentsInResponse: [PostComment] {
        postManager.getCommentsInResponseToPost(post, allComments: comments)
    }
    
    private var isSelfOwned: Bool {
        accountManager.loggedInUser?.id == post.postedBy
    }
    
    private func onPressReplyButton() {
        isFieldReplyFocused = true
    }
    
    private func onPressSubmitReplyButton() {
        if fieldReplyContents.trimmed.isEmpty {
            buttonSubmitReplyAnimate = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                buttonSubmitReplyAnimate = 0
            }
            return
        }
        
        let loggedInUser = accountManager.loggedInUser
        
        if loggedInUser == nil {
            
            return
        }
        
        buttonSubmitReplyAnimate = 2
        let new = PostComment(body: fieldReplyContents, postedBy: accountManager.loggedInUser!, attachedTo: post)
        modelContext.insert(new)
        try? modelContext.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            buttonSubmitReplyAnimate = 0
            fieldReplyContents = ""
        }
        // TODO Submit the new model
    }
    
    var body: some View {
        let user = users.first { that in
            that.id == post.postedBy
        }
        let username = user?.username ?? "Unknown"
        
        return VStack(spacing: 0) {
            sectionPostBody
                .padding(.top, 8)
                .padding(.horizontal)
            rowPostedBy
                .padding(.top, 4)
                .padding(.horizontal)
            sectionUserDependentControls
                .padding(.top)
                .padding(.horizontal)
            sectionNewReply
                .padding(.top)
                .padding(.horizontal)
            sectionDisplayReplies
                .padding(.top)
            
            Spacer()
        }
        .navigationTitle("Post by @\(username)")
    }
    
    private var rowPostedBy: some View {
        let formatter = DateFormatter()
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
//      formatter.dateFormat = "MMMM dd'th', yyyy 'at' h:mm a"  // Old
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"     // American
//      formatter.dateFormat = "yyyy'-'MM'-'dd 'at' h:mm a" // International
        let createdFmt = formatter.string(from: createdDate)
        
        let user = users.first { that in
            that.id == post.postedBy
        }
        
        return HStack(spacing: 3) {
            if user != nil {
                NavigationLink(destination: UserProfileView(user: user!)) {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 20, height: 20)
                        Text("@\(user!.username)")
                            .foregroundStyle(.blue)
                    }
                }
            } else {
                Text("@Unknown")
                    .foregroundStyle(.blue)
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
        func onPress() {
            modelContext.delete(post)
            try? modelContext.save()
            dismiss()
        }
        
        return Button(action: onPress) {
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
    
    @ViewBuilder
    private var buttonSubmitReplyLabel: some View {
        switch (buttonSubmitReplyAnimate) {
            case 1: Image(systemName: "xmark")
            case 2: Image(systemName: "checkmark")
            default: Text("Reply")
        }
    }
    
    private var buttonSubmitReply: some View {
        let tintColor = switch (buttonSubmitReplyAnimate) {
            case 1:  Color.red
            case 2:  Color.green
            default: Color.blue
        }
        
        return Button(action: onPressSubmitReplyButton) {
            buttonSubmitReplyLabel
                .frame(width: 60)
        }
        .buttonStyle(.bordered)
        .tint(tintColor)
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
    
    private var sectionNewReply: some View {
        let user = users.first {
            $0.id == post.postedBy
        }
        let username = user?.username ?? "Unknown"
        
        return HStack {
            TextField(text: $fieldReplyContents, prompt: Text("Your reply to \(username)")) {
                Text("Enter your new reply")
            }
            .textFieldStyle(.roundedBorder)
            .focused($isFieldReplyFocused)
            
            buttonSubmitReply
        }
    }
    
    private func getViewForComment(_ comment: PostComment) -> some View {
        let formatter = DateFormatter()
        let createdDate = Date(timeIntervalSince1970: comment.createdAt)
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: createdDate)
        
        let user = users.first {
            $0.id == post.postedBy
        }
        let username = user?.username ?? "Unknown"
        
        return HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 3) {
                    Text("@\(username)")
                        .foregroundStyle(.blue)
                    Text("at \(createdFmt)")
                    Spacer()
                }
                .font(.caption)
                
                Text("\"\(comment.body)\"")
            }
            Spacer()
        }
    }
    
    private var sectionDisplayReplies: some View {
        let comments   = getCommentsInResponse
        let replyCount = comments.count
        
        return VStack(alignment: .leading) {
            Text("Replies (\(replyCount))")
                .font(.title)
                .bold()
                .padding(.horizontal)
            List {
                ForEach(comments) { comment in
                    getViewForComment(comment)
                }
            }
            .listStyle(.plain)
        }
    }
}

//#Preview {
//    let user = UserAccount(username: "Tyler", password: "Password")
//    let mockPost = BlogPost(body: "Lorem ipsum dolor this is my fake blog post", postedBy: user)
//    return DisplayPostPage(mockPost)
//        .environmentObject(UserAccountManager())
//}
