import SwiftUI

private func shortenFollowerCount(_ n: Int) -> String {
    if n <= 999 {
        return "\(n)"
    }
    
    let nd  = Double(n) / 1000.0
    let fmt = String(format: "%.1f", nd)
    return "\(fmt)K"
}

struct FollowerCountView: View {
    
    @Environment(\.colorScheme)
    private var systemColorScheme
    
    let followers: Int
    let following: Int
    
    var body: some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Material.ultraThin)
                .frame(width: 180)
                .frame(height: 50)
            HStack {
                VStack {
                    Text("Followers")
                        .fontWeight(.semibold)
                    Text("\(shortenFollowerCount(followers))")
                }
                Divider()
                    .frame(maxHeight: 35)
                VStack {
                    Text("Following")
                        .fontWeight(.semibold)
                    Text("\(shortenFollowerCount(following))")
                }
            }
        }
    }
}

struct NewFollowerCountView: View {
    
    private let user: UserAccount
    private let followers: Int
    private let following: Int
    
    init(user: UserAccount, followers: Int, following: Int) {
        self.user = user
        self.followers = followers
        self.following = following
    }
    
    @State
    private var isSectionLeadingPressed = false
    @State
    private var isSectionTrailingPressed = false
    
    public var body: some View {
        return HStack(spacing: 1) {
            sectionLeading
            sectionTrailing
        }
        .frame(minHeight: 45)
        .frame(maxWidth: 200, maxHeight: 55)
//        .border(.red)
    }
    
    private var sectionLeading: some View {
        return NavigationLink(destination: Text("\(user.username)'s followers page")) {
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .circular)
                    .fill(Material.ultraThin)
                VStack {
                    Text("Followers")
                        .fontWeight(.semibold)
                    Text("\(shortenFollowerCount(followers))")
                }
                .padding(.vertical, 5)
                .allowsHitTesting(false)
            }
        }
        .foregroundStyle(.primary)
    }
    
    private var sectionTrailing: some View {
        // TODO Proper navigation destination
        return NavigationLink(destination: Text("\(user.username)'s following page")) {
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 8, topTrailingRadius: 8, style: .circular)
                    .fill(Material.ultraThin)
                    .frame(minHeight: 45)
                VStack {
                    Text("Following")
                        .fontWeight(.semibold)
                    Text("\(shortenFollowerCount(following))")
                }
                .padding(.vertical, 5)
            }
        }
        .foregroundStyle(.primary)
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
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                Text("Old")
                    .font(.largeTitle)
                VStack {
                    FollowerCountView(followers: 100, following: 1000)
                    FollowerCountView(followers: 0, following: 10)
                    FollowerCountView(followers: 69555, following: 5678)
                }
                Text("New")
                    .font(.largeTitle)
                VStack {
                    NewFollowerCountView(user: mockUser, followers: 100, following: 1000)
                    NewFollowerCountView(user: mockUser, followers: 0, following: 10)
                    NewFollowerCountView(user: mockUser, followers: 69555, following: 5678)
                }
            }
        }
    }
}
