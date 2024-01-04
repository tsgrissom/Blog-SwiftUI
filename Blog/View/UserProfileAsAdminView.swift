import SwiftUI
import SwiftData

struct UserProfileAsAdminView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
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
    @State
    private var displaySectionUserSecrets = false
    
    private var isOwnAccount: Bool {
        accountManager.loggedInUser?.id == user.id
    }
    
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
    
    private var textPermissionLevel: some View {
        let level = user.permissionLevel
        let title = switch level {
        case 1: "Subscriber"
        case 2: "Moderator"
        case 3: "Operator"
        case 4: "Superuser"
        default: "Default"
        }
        let selfId = accountManager.loggedInUser?.id
        
        return HStack {
            Text("Rank: \(title) (\(level))")
            Spacer()
            if user.permissionLevel != 4 && user.id != selfId {
                buttonPromote
                buttonDemote
            }
        }
    }
    
    private var textInferiorRank: some View {
        let bool = user.isRankInferiorTo(accountManager.loggedInUser)
        let binaryWord = bool ? "Yes" : "No"
        return Text("Inferior Rank: \(binaryWord)")
    }
    
    private var textSuperiorRank: some View {
        let bool = user.isRankSuperiorTo(accountManager.loggedInUser)
        let binaryWord = bool ? "Yes" : "No"
        return Text("Superior Rank: \(binaryWord)")
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
    
    private var textPassword: some View {
        return HStack {
            Text("Password: \(user.password)")
            Spacer()
            
            if !isOwnAccount {
                Button("Log In As") {
                    accountManager.loggedInUser = user
                    dismiss()
                }
            }
        }
    }
    
    private var buttonDelete: some View {
        func onPress() {
            isConfirmDeletePresented = true
        }
        
        func onConfirm() {
            if user.isSuperUser() {
                return
            }
            
            isConfirmDeletePresented = false
            modelContext.delete(user)
            try? modelContext.save()
            dismiss()
        }
        
        return Button("Delete", systemImage: "trash") {
            onPress()
        }
        .buttonStyle(.bordered)
        .disabled(user.isSuperUser())
        .tint(.red)
        .foregroundStyle(.red)
        .confirmationDialog("Delete user \"\(user.username)\"? (Cannot be undone)", isPresented: $isConfirmDeletePresented, titleVisibility: .visible, actions: {
            Button("Confirm", role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel) {
                isConfirmDeletePresented = false
            }
        })
    }
    
    private var buttonPromote: some View {
        func onPress() {
            let thisUser = accountManager.loggedInUser
            let thatUser = user
            
            if thisUser == nil { // Logged in user might be nil
                return
            }
            
            if !thisUser!.isRankSuperiorTo(thatUser) { // If promoting user is inferior to promoted user, cannot promote
                // TODO Feedback
                return
            }
            
            if thatUser.permissionLevel >= 3 { // If the promoted user is already operator or superuser, cannot be promoted
                return
            }
            
            let current = thatUser.permissionLevel
            
            thatUser.permissionLevel = current + 1
            try? modelContext.save()
        }
        
        func isDisabled() -> Bool {
            user.isRankSuperiorTo(accountManager.loggedInUser) || // Cannot promote a superior user
            user.permissionLevel == accountManager.loggedInUser?.permissionLevel || // Cannot promote an equal user
            user.permissionLevel >= 3 // Cannot promote past operator
        }
        
        return Button(action: onPress) {
            Image(systemName: "arrow.up")
                .imageScale(.small)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
        .disabled(isDisabled())
    }
    
    private var buttonDemote: some View {
        func onPress() {
            let thisUser: UserAccount?  = accountManager.loggedInUser
            let thatUser: UserAccount   = user
                
            if thisUser == nil {
                return
            }
            
            let thisLevel = thisUser!.permissionLevel
            let thatLevel = thatUser.permissionLevel
            
            // TODO Feedback
            if thatLevel == 4 {  // Superuser cannot be demoted
                return
            }
            
            if thatLevel == 3 && thisLevel < 4 { // Operators can only be demoted by superuser, not by other operators
                return
            }
            
            if thisUser!.isRankInferiorTo(thatUser) {
                return
            }
            
            if thatLevel == 0 { // Cannot demote lower than default
                return
            }
            
            let current = thatUser.permissionLevel
            
            thatUser.permissionLevel = current - 1
            try? modelContext.save()
        }
        
        func isDisabled() -> Bool {
            user.isRankSuperiorTo(accountManager.loggedInUser) || // Cannot demote a superior user
            user.permissionLevel == 0 || // Cannot demote lower than default
            user.permissionLevel == 4    // Cannot demote a superuser
        }
        
        return Button(action: onPress) {
            Image(systemName: "arrow.down")
                .imageScale(.small)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
        .disabled(isDisabled())
    }
    
    @ViewBuilder
    private var buttonDisplaySecrets: some View {
        let isSuperUser = accountManager.loggedInUser?.isSuperUser() ?? false
        
        if isSuperUser {
            Button("Display Secrets") {
                displaySectionUserSecrets.toggle()
            }
            .buttonStyle(.bordered)
            .tint(.yellow)
        } else {
            EmptyView()
        }
    }
    
    public var body: some View {
        VStack {
            List {
                Section("User Data") {
                    textInternalId
                    textJoined
                    textPermissionLevel
                    textInferiorRank
                    textSuperiorRank
                }
                
                Section("User-Configured") {
                    textUsername
                    textDisplayName
                    textBiography
                }
                
                if displaySectionUserSecrets {
                    Section("User Secrets") {
                        textPassword
                    }
                }
                
                Section("Statistics") {
                    textPostsCount
                    textCommentsCount
                }
                
                Section("Controls") {
                    HStack {
                        buttonDelete
                        // TODO Force rename
                        // TODO Force clear bio
                    }
                    HStack {
                        buttonDisplaySecrets
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
        UserProfileAsAdminView(mockUser)
    }
    .environmentObject(UserAccountManager())
}
