import SwiftUI

struct AccountManagementPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    public var body: some View {
        NavigationStack {
            if accountManager.isLoggedIn {
                DisplayUserProfilePage(user: accountManager.loggedInUser!)
            } else {
                NotLoggedInView()
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
