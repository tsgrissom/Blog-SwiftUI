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
    private var comments: [PostComment]
    @Query
    private var posts: [Post]
    
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
    
    @State
    private var alertBoxColor = Color.red
    @State
    private var alertBoxVisible = false
    @State
    private var alertBoxText = "Alert Box"
    @State
    private var alertBoxDebounce = false
    
    private var isOwnAccount: Bool {
        accountManager.loggedInUser?.id == user.id
    }
    
    private func flashAlert(
        _ text: String,
        color: Color = .red
    ) {
        // TODO Haptics
        if alertBoxDebounce {
            return
        }
        
        alertBoxDebounce = true
        alertBoxText = text
        alertBoxColor = color
        withAnimation {
            alertBoxVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                alertBoxVisible = false
            }
            alertBoxText = "Alert Box"
            alertBoxColor = .red
            alertBoxDebounce = false
        }
    }
    
    private var textInternalId: some View {
        func onPress() {
            UIPasteboard.general.string = user.id
            animateTextInternalIdCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                animateTextInternalIdCopied = false
            }
        }
        
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
            onPress()
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
        let title = user.getRankTitle()
        let selfId = accountManager.loggedInUser?.id
        let shouldPresent = level != 4 && user.id != selfId
        
        return HStack {
            Text("Rank: \(title) (\(level))")
            Spacer()
            if shouldPresent {
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
        let associatedComments = user.getAllComments(allComments: comments)
        return Text("Comments made: \(associatedComments.count)")
    }
    
    private var textPostsCount: some View {
        let associatedPosts = user.getAllPosts(allPosts: posts)
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
        
        return Button("Delete") {
            onPress()
        }
        .buttonStyle(.bordered)
        .disabled(user.isSuperUser())
        .tint(.red)
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
                flashAlert("You must be logged in to promote another user")
                return
            }
            
            if thisUser!.isRankInferiorTo(thatUser) { // If promoting user is inferior to promoted user, cannot promote
                // TODO Feedback
                flashAlert("You cannot promote a user of higher rank than you")
                return
            }
            
            if thatUser.permissionLevel >= 3 { // If the promoted user is already operator or superuser, cannot be promoted
                flashAlert("Operators cannot be promoted any further")
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
        .tint(isDisabled() ? .gray : .blue)
    }
    
    private var buttonDemote: some View {
        let thisUser: UserAccount?  = accountManager.loggedInUser
        let thatUser: UserAccount   = user
        
        func onPress() {
            if thisUser == nil {
                flashAlert("You must be logged in to demote a user")
                return
            }
            
            let thisLevel = thisUser!.permissionLevel
            let thatLevel = thatUser.permissionLevel
            
            // TODO Feedback
            if thatLevel == 4 {  // Superuser cannot be demoted
                flashAlert("Superusers cannot be demoted")
                return
            }
            
            if thatLevel == 3 && thisLevel < 4 { // Operators can only be demoted by superuser, not by other operators
                flashAlert("Operators cannot be demoted by anyone but the Superuser")
                return
            }
            
            if thisUser!.isRankInferiorTo(thatUser) {
                flashAlert("\(thisUser!.username) is of lesser rank than \(thatUser.username)")
                return
            }
            
            if thatLevel == 0 { // Cannot demote lower than default
                flashAlert("Cannot demote lower than Default")
                return
            }
            
            let current = thatUser.permissionLevel
            
            thatUser.permissionLevel = current - 1
            try? modelContext.save()
        }
        
        func isDisabled() -> Bool {
            thatUser.isRankSuperiorTo(thisUser) || // Cannot demote a superior user
            thatUser.permissionLevel == 0 || // Cannot demote lower than default
            thatUser.permissionLevel == 4    // Cannot demote a superuser
        }
        
        return Button(action: onPress) {
            Image(systemName: "arrow.down")
                .imageScale(.small)
        }
        .buttonStyle(.bordered)
        .tint(isDisabled() ? .gray : .blue)
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
        GeometryReader { geometry in
            ZStack {
                sectionList
                
                if alertBoxVisible {
                    sectionAlertBox
                        .offset(x: 0, y: -(geometry.size.width*0.80))
                        .transition(.move(edge: .top))
                        .onTapGesture {
                            withAnimation {
                                alertBoxVisible = false
                            }
                        }
                }
            }
        }
        .navigationTitle("Admin View: User @\(user.username)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var sectionAlertBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(alertBoxColor)
                .padding(.horizontal)
            VStack {
                Text(alertBoxText)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
            }
        }
        .frame(minHeight: 35)
        .frame(maxHeight: 55)
    }
    
    private var sectionList: some View {
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
                    
                    buttonDisplaySecrets
                }
            }
        }
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