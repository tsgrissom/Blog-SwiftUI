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
        let bgColor = systemColorScheme == .dark ? Color.black : Color.white
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(bgColor)
                .frame(width: 180)
                .frame(height: 50)
            HStack {
                VStack {
                    Text("Followers")
                    Text("\(shortenFollowerCount(followers))")
                }
                Divider()
                    .frame(maxHeight: 35)
                VStack {
                    Text("Following")
                    Text("\(shortenFollowerCount(following))")
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            VStack {
                FollowerCountView(followers: 100, following: 1000)
                FollowerCountView(followers: 0, following: 10)
                FollowerCountView(followers: 69555, following: 5678)
            }
        }
    }
}
