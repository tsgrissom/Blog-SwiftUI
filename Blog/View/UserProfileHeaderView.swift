import LoremSwiftum
import SwiftUI

struct UserProfileHeaderView: View {
    
    // MARK: Environment
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: Initialization
    private let user: UserAccount
    
    init(_ user: UserAccount) {
        self.user = user
    }
    
    // MARK: State
    @State
    private var isPresentingConfirmModifyUsername = false
    @State
    private var isPresentingModifyBiographySheet = false
    @State
    private var isPresentingModifyDisplayNameSheet = false
    @State
    private var isPresentingModifyUsernameSheet = false
    
    // MARK: Layout Declaration
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            textDisplayNameAsTitle
                .onTapGesture {
                    isPresentingModifyDisplayNameSheet.toggle()
                }
                .sheet(isPresented: $isPresentingModifyDisplayNameSheet, content: {
                    UserModifyProfileFieldView(mode: .displayName)
                })
            
            textUsernameAsSubtitle
                .onTapGesture {
                    isPresentingConfirmModifyUsername.toggle()
                }
                .confirmationDialog(
                    "Are you sure you want to change your username? (@username)",
                    isPresented: $isPresentingConfirmModifyUsername,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive, action: {
                        isPresentingConfirmModifyUsername = false
                        isPresentingModifyUsernameSheet = true
                    }) {
                        Text("Proceed")
                    }
                    Button(role: .cancel, action: {}) {
                        Text("Cancel")
                    }
                }
                .sheet(isPresented: $isPresentingModifyUsernameSheet, content: {
                    UserModifyProfileFieldView(mode: .username)
                })
            
            HStack {
                textBiography
                    .onTapGesture {
                        isPresentingModifyBiographySheet.toggle()
                    }
                    .sheet(isPresented: $isPresentingModifyBiographySheet, content: {
                        UserModifyProfileFieldView(mode: .biography)
                    })
                
                Spacer()
            }
        }
    }
}

// MARK: Views
extension UserProfileHeaderView {
    
    // MARK: Text
    @ViewBuilder
    private var textBiography: some View {
        if user.biography.isEmpty {
            Text("This user has not set a biography.")
                .italic()
        } else {
            Text(user.biography)
        }
    }
    
    private var textDisplayNameAsTitle: some View {
        Text(user.displayName)
            .font(.title)
            .bold()
    }
    
    private var textUsernameAsSubtitle: some View {
        Text("@\(user.username)")
            .font(.title3)
    }
}

// MARK: Previews
#Preview {
    func generateViewForMockUser() -> some View {
        let biography = LoremSwiftum.Lorem.shortTweet
        let mockUser = MockupUtilities.getMockUser()
        mockUser.biography = Bool.random() ? biography : ""
        
        return UserProfileHeaderView(mockUser)
    }
    
    return ScrollView {
        VStack {
            ForEach(1...10, id: \.self) { _ in
                generateViewForMockUser()
            }
        }
        .padding(.horizontal)
    }
    .environmentObject(UserAccountManager())
}
