import SwiftUI

struct ButtonRepost: View {
    
    @State
    private var reposted: Bool
    // 0=default,1=unliked,2=liked
    @State
    private var animateScale: Int
    @State
    private var debounce: Bool
    @State
    private var isPresentingConfirmUndoRepost: Bool
    
    init(reposted: Bool = false) {
        self.reposted = reposted
        self.animateScale = 0
        self.debounce = false
        self.isPresentingConfirmUndoRepost = false
    }
    
    private func onPress() {
        if debounce {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        if reposted {
            isPresentingConfirmUndoRepost = true
        } else {
            onConfirm()
        }
    }
    
    private func onConfirm() {
        debounce = true
        if reposted {
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
        reposted.toggle()
    }
    
    public var body: some View {
        let tint: Color = reposted ? .accentColor : .secondary
        let symbolScale = switch animateScale {
            case 1:  0.95
            case 2:  1.1
            default: 1.0
        }
        
        return Button(action: onPress) {
            Image(systemName: "arrow.rectanglepath")
                .bold()
                .imageScale(.large)
                .scaleEffect(symbolScale)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .offset(y: -1.5)
        }
        .buttonStyle(.plain)
        .foregroundStyle(tint)
        .confirmationDialog("Are you sure you want to undo your repost?", isPresented: $isPresentingConfirmUndoRepost, titleVisibility: .visible) {
            Button("Undo", role: .destructive, action: {
                isPresentingConfirmUndoRepost = false
                onConfirm()
            })
            Button("Cancel", role: .cancel, action: {
                isPresentingConfirmUndoRepost = false
            })
        }
    }
}

#Preview {
    HStack {
        VStack {
            Text("Not Reposted")
            ButtonRepost(reposted: false)
        }
        VStack {
            Text("Reposted")
            ButtonRepost(reposted: true)
        }
    }
}
