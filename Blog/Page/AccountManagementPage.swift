import SwiftUI

struct AccountManagementPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    public var body: some View {
        NavigationStack {
            if accountManager.isLoggedIn {
                DisplayUserProfilePage(accountManager.loggedInUser!)
            } else {
                NotLoggedInView(verticalNavLinks: true)
                    .padding(.top)
                    .navigationTitle("Your Profile")
            }
        }
    }
}

#Preview {
    AccountManagementPage()
        .environmentObject(UserAccountManager())
}
