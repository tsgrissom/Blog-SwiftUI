import LoremSwiftum
import SwiftUI

struct UserAtTimeView: View {
    
    // MARK: Initialization
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
    
    // MARK: Layout Declaration
    public var body: some View {
        HStack(spacing: 3) {
            navLinkUser
            textCreatedAt
            
            Spacer()
        }
        .font(.caption)
    }
}

// MARK: Views
extension UserAtTimeView {
    
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

// MARK: Previews
#Preview {
    func generateViewForMockUser() -> some View {
        let now = Date()
        let mockUser = MockupUtilities.getMockUser()
        
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
