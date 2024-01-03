import SwiftUI
import SwiftData

struct UserAccountAdminView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    
    @Query
    private var comments: [BlogComment]
    @Query
    private var posts: [BlogPost]
    
    private let user: UserAccount
    
    init(_ user: UserAccount) {
        self.user = user
    }
    
    @State
    private var animateTextInternalIdCopied = false
    @State
    private var isConfirmDeletePresented = false
    
    private func onPressTextInternalId() {
        UIPasteboard.general.string = user.id
        animateTextInternalIdCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animateTextInternalIdCopied = false
        }
    }
    
    private var textInternalId: some View {
        let blobId  = "Internal ID: \(user.id)"
        let fgColor = animateTextInternalIdCopied ? Color.green : Color.primary
        let text    = animateTextInternalIdCopied ? "Copied to clipboard" : blobId
        return HStack {
            ScrollView(.horizontal) {
                Text(text)
                    .foregroundStyle(fgColor)
                    .padding(.vertical, 5)
            }
        }
        .onTapGesture {
            onPressTextInternalId()
        }
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
    
    private var buttonDelete: some View {
        func onPress() {
            isConfirmDeletePresented = true
        }
        
        func onConfirm() {
            isConfirmDeletePresented = false
            modelContext.delete(user)
            try? modelContext.save()
            dismiss()
        }
        
        return Button("Delete", systemImage: "trash") {
            onPress()
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .foregroundStyle(.red)
        .confirmationDialog("Delete user \"\(user.username)\"? (Cannot be undone)", isPresented: $isConfirmDeletePresented, titleVisibility: .visible, actions: {
            Button("Confirm", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel) {
                isConfirmDeletePresented = false
            }
        })
    }
    
    public var body: some View {
        VStack {
            List {
                Section("Fixed") {
                    textInternalId
                    textJoined
                }
                
                Section("Statistics") {
                    textPostsCount
                    textCommentsCount
                }
                
                Section("User-Configured") {
                    textUsername
                    textDisplayName
                    textBiography
                }
                
                Section("Controls") {
                    HStack {
                        buttonDelete
                        // TODO Force rename
                        // TODO Force clear bio
                        
                    }
                }
            }
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
