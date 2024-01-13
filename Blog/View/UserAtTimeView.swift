import LoremSwiftum
import SwiftUI

struct UserAtTimeView: View {
    
    private let user: UserAccount
    private let time: Date
    private let withProfilePicture: Bool
    private let profilePictureLength: CGFloat
    
    init(
        user: UserAccount,
        at time: Date,
        withProfilePicture: Bool = false,
        profilePictureLength: CGFloat = 20.0
    ) {
        self.user = user
        self.time = time
        self.withProfilePicture = withProfilePicture
        self.profilePictureLength = profilePictureLength
    }
    
    public var body: some View {
        HStack(spacing: 3) {
            navLinkUser
            textCreatedAt
            
            Spacer()
        }
        .font(.caption)
    }
    
    private var navLinkUser: some View {
        HStack(spacing: 3) {
            if withProfilePicture {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: profilePictureLength, height: profilePictureLength)
            }
            
            Text("@\(user.username)")
                .foregroundStyle(Color.accentColor)
        }
    }
    
    private var textCreatedAt: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"
        let createdFmt = formatter.string(from: time)
        
        return Text("at \(createdFmt)")
    }
}

#Preview {
    func generateViewForMockUser() -> some View {
        let firstName = LoremSwiftum.Lorem.firstName
        let lastName = LoremSwiftum.Lorem.lastName
        let now = Date()
        let mockUser = UserAccount(username: firstName, password: "Password")
        mockUser.displayName = "\(firstName)\(lastName)"
        
        return UserAtTimeView(user: mockUser, at: now, withProfilePicture: Bool.random())
    }
    
    return NavigationStack {
        VStack {
            ForEach(1...10, id: \.self) { _ in
                generateViewForMockUser()
            }
        }
    }
}
