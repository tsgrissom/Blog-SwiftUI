import SwiftUI
import SwiftData

struct ButtonFollowingStatus: View {
    
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    @Query
    private var followingRelationships: [FollowingRelationship]
    
    private let targetUser: UserAccount
    private let currentUser: UserAccount?
    
    init(_ targetUser: UserAccount, currentUser: UserAccount?) {
        self.targetUser = targetUser
        self.currentUser = currentUser
    }
    
    private var isFollowing: Bool {
        return currentUser?.isFollowing(targetUser, allRelationships: followingRelationships) ?? false
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let mockUser = MockupUtilities.getMockUser()
    let mockCurrentUser = UserAccount(username: "Tyler", password: "Password")
    
    return ButtonFollowingStatus(mockUser, currentUser: mockCurrentUser)
        .environmentObject(UserAccountManager())
}
