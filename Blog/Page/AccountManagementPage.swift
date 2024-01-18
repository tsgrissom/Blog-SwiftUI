import SwiftUI

struct AccountManagementPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    public var body: some View {
        NavigationStack {
            if accountManager.isLoggedIn {
                DisplayUserProfilePage(accountManager.loggedInUser!)
            } else {
                AccountNotLoggedInView(verticalNavLinks: true)
                    .navigationTitle("Your Profile")
            }
        }
    }
}

#Preview {
    AccountManagementPage()
        .environmentObject(UserAccountManager())
}
