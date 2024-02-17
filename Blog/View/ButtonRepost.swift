import SwiftUI

struct ButtonRepost: View {
    
    @State
    private var reposted: Bool
    @State
    private var isPresentingConfirmUndo: Bool
    
    private let requireConfirmUndo: Bool
    
    init(reposted: Bool = false, requireConfirmation: Bool = true) {
        self.reposted = reposted
        self.isPresentingConfirmUndo = false
        self.requireConfirmUndo = requireConfirmation
    }
    
    private func onPress() {
        if requireConfirmUndo && reposted {
            isPresentingConfirmUndo.toggle()
        } else {
            onConfirm()
        }
    }
    
    private func onConfirm() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        reposted.toggle()
    }
    
    public var body: some View {
        let tint: Color = reposted ? .accentColor : .secondary
        
        return Button(action: onPress) {
            Image(systemName: "arrow.rectanglepath")
                .bold()
                .imageScale(.large)
//                .rotation3DEffect(.degrees(180.0), axis: (x: 0, y: 1, z: 0))
                .offset(y: -1.5)
                .symbolEffect(reposted ? .bounce.wholeSymbol.up  : .bounce.wholeSymbol.down, value: reposted)
                .foregroundStyle(tint)
        }
        .buttonStyle(.plain)
        .tint(tint)
        .confirmationDialog("Are you sure you want to undo your repost?", isPresented: $isPresentingConfirmUndo, titleVisibility: .visible) {
            buttonConfirm
            buttonCancel
        }
    }
}

extension ButtonRepost {
    
    private var buttonConfirm: some View {
        Button("Undo Repost", role: .destructive, action: {
            isPresentingConfirmUndo = false
            onConfirm()
        })
    }
    
    private var buttonCancel: some View { 
        Button("Cancel", role: .cancel, action: {
            isPresentingConfirmUndo = false
        })
    }
}

#Preview {
    HStack {
        VStack {
            Text("Not Reposted")
            ButtonRepost(reposted: false, requireConfirmation: false)
        }
        VStack {
            Text("Reposted")
            ButtonRepost(reposted: true, requireConfirmation: false)
        }
    }
}
