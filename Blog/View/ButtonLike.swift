import SwiftUI

struct ButtonLike: View {
    
    @State
    private var liked: Bool
    // 0=default,1=unliked,2=liked
    @State
    private var animateScale: Int
    @State
    private var debounce: Bool
    
    init(liked: Bool = false) {
        self.liked = liked
        self.animateScale = 0
        self.debounce = false
    }
    
    private func onPress() {
        if debounce {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        debounce = true
        if liked {
            withAnimation(.easeInOut(duration: 0.15)) {
                animateScale = 1
            } completion: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    animateScale = 0
                }
                debounce = false
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                animateScale = 2
            } completion: {
                withAnimation {
                    animateScale = 0
                }
                debounce = false
            }
        }
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        liked.toggle()
    }
    
    public var body: some View {
        let tint = liked ? Color.pink : Color.secondary
        let symbolName = liked ? "heart.fill" : "heart"
        let symbolScale = switch animateScale {
            case 1: 0.9
            case 2: 1.2
            default: 1.0
        }
        
        return Button(action: onPress) {
            Image(systemName: symbolName)
                .imageScale(.large)
                .scaleEffect(symbolScale)
        }
        .buttonStyle(.plain)
        .foregroundStyle(tint)
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
