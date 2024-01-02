import SwiftUI

struct AccountManagementPage: View {
    
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    public var body: some View {
        NavigationStack {
            if accountManager.isLoggedIn {
                UserProfileView(user: accountManager.loggedInUser!)
            } else {
                VStack(alignment: .leading) {
                    rowNotLoggedIn
                }
                .navigationTitle("Your Profile")
            }
        }
    }
    
    private var rowNotLoggedIn: some View {
        HStack {
            NavigationLink(destination: RegisterUserAccountPage()) {
                Text("Register")
            }
            NavigationLink(destination: LoginUserAccountPage()) {
                Text("Login")
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    AccountManagementPage()
        .environmentObject(UserAccountManager())
}
