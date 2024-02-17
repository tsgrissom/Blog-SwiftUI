import SwiftUI

struct ButtonLike: View {
    
    @State
    private var liked: Bool
    
    init(liked: Bool = false) {
        self.liked = liked
    }
    
    private func onPress() {
        liked.toggle()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    public var body: some View {
        let tint = liked ? Color.pink : Color.secondary
        
        return Button(action: onPress) {
            ZStack {
                Image(systemName: "heart.fill")
                    .opacity(liked ? 1.0 : 0.0)
                Image(systemName: "heart")
                    .symbolEffect(liked ? .bounce.wholeSymbol.up : .bounce.wholeSymbol.down, value: liked)
            }
            .bold()
            .foregroundStyle(tint)
            .imageScale(.large)
        }
        .buttonStyle(.plain)
        .tint(tint)
    }
}

#Preview {
    HStack {
        VStack {
            Text("Not Liked")
            ButtonLike(liked: false)
        }
        
        VStack {
            Text("Liked")
            ButtonLike(liked: true)
        }
    }
}
