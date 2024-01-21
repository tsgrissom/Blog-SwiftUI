import LoremSwiftum
import SwiftUI
import SwiftData

struct DisplayPostPage: View {
    
    // MARK: Environment
    @EnvironmentObject
    private var accountManager: UserAccountManager
    @EnvironmentObject
    private var postManager: PostManager
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    
    // MARK: SwiftData Queries
    @Query
    private var posts: [Post]
    @Query
    private var comments: [PostComment]
    @Query
    private var users: [UserAccount]
    
    // MARK: Initialization
    private let post: Post
    
    init(_ post: Post) {
        self.post = post
    }
    
    // MARK: State
    @State
    private var fieldReplyContents = ""
    @FocusState
    private var isFieldReplyFocused: Bool
    // 0=default,1=error,2=success
    @State
    private var buttonSubmitReplyAnimate = 0
    
    // MARK: Helper Variables
    private var getCommentsInResponse: [PostComment] {
        postManager.getCommentsInResponseToPost(post, allComments: comments)
    }
    
    private var isSelfOwned: Bool {
        accountManager.loggedInUser?.id == post.postedBy
    }
    
    // MARK: Button Handlers
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            buttonSubmitReplyAnimate = 0
        }
        
        let new = PostComment(body: fieldReplyContents, postedBy: accountManager.loggedInUser!, attachedTo: post)
        modelContext.insert(new)
        try? modelContext.save()
        
        fieldReplyContents = ""
    }
    
    // MARK: Layout Declaration
    var body: some View {
        let user = users.first { $0.id == post.postedBy }
        
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
        .navigationTitle("Post by @\(user.getUsername())")
    }
}

extension DisplayPostPage {
    
    // MARK: Button Views
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
    
    // MARK: List Views
    private var listPostReplies: some View {
        let attached = getCommentsInResponse
        
        return List {
            ForEach(attached) { comment in
                getCommentTreeView(comment)
                    .swipeActions(edge: .trailing) {
                        if comment.isOwnedBy(accountManager.loggedInUser) {
                            Button("Delete") {
                                modelContext.delete(comment)
                                try? modelContext.save()
                            }
                            .tint(.red)
                        }
                    }
            }
        }
    }
    
    // MARK: Text Views
    private var textRepliesHeader: some View {
        let comments = getCommentsInResponse
        let count = comments.count
        
        let text = count==0 ? "No Replies" : "Replies (\(count))"
        
        return Text(text)
            .font(.title)
            .bold()
            .padding(.horizontal, 18)
    }
    
    // MARK: Row Views
    @ViewBuilder
    private var rowPostedBy: some View {
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
        let user = users.first {
            $0.id == post.postedBy
        }
        
        if user != nil {
            UserAtTimeView(user: user!, at: createdDate)
        } else {
            rowPostedByUnknown
        }
    }
    
    private var rowPostedByUnknown: some View {
        let formatter = DateFormatter()
        let createdDate = Date(timeIntervalSince1970: post.createdAt)
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"    // American
        let createdFmt = formatter.string(from: createdDate)
        
        return HStack(spacing: 3) {
            Text("@Unknown")
                .foregroundStyle(.blue)
            Text("at \(createdFmt)")
            Spacer()
        }
        .font(.caption)
    }
    
    // MARK: Section Views
    private var sectionPostBody: some View {
        HStack {
            Text(post.body)
            Spacer()
        }
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
        let user = users.first { $0.id == post.postedBy }
        
        return HStack {
            TextField(
                text: $fieldReplyContents,
                prompt: Text("Your reply to \(user.getUsername())")
            ) {
                Text("Enter your new reply")
            }
            .textFieldStyle(.roundedBorder)
            .focused($isFieldReplyFocused)
            
            buttonSubmitReply
        }
    }
    
    private func getCommentTreeView(_ comment: PostComment) -> some View {
        let children = comment.getChildComments(allComments: comments)
        return NavigationLink(destination: DisplayCommentPage(comment)) {
            CommentTreeView(comment, children: children, mode: .collapsedAfterOne)
        }
    }
    
    private var sectionDisplayReplies: some View {
        return VStack(alignment: .leading) {
            textRepliesHeader
            
            listPostReplies
                .listStyle(.plain)
        }
    }
}

// MARK: Previews
#Preview {
    let mockUser = MockupUtilities.getMockUser()
    let mockPost = MockupUtilities.getMockPost(by: mockUser)
    
    return NavigationStack {
        DisplayPostPage(mockPost)
    }
    .environmentObject(UserAccountManager())
    .environmentObject(PostManager())
}
