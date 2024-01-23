import LoremSwiftum
import SwiftUI

enum CommentTreeDisplayMode: CaseIterable {
    case all
    case collapseAfterOne
    case collapseAll
}

struct CommentTreeView: View {
    
    // MARK: Initialization
    private let parent: PostComment
    private let children: [PostComment]
    
    @State
    private var mode: CommentTreeDisplayMode
    
    init(
        _ parent: PostComment,
        children: [PostComment],
        mode: CommentTreeDisplayMode = .all
    ) {
        self.parent = parent
        self.children = children
        self.mode = mode
    }
    
    // MARK: Helpers
    private func getViewForChild(
        text: String,
        action: @escaping () -> Void
    ) -> some View {
        return HStack {
            Button(action: {
                action()
            }) {
                Image(systemName: "arrow.turn.down.right")
            }
            .buttonStyle(.plain)
            
            Text(text)
                .font(.caption)
            Spacer()
        }
    }
    
    private func getViewForChildComment(
        _ comment: PostComment,
        action: @escaping () -> Void
    ) -> some View {
        return HStack {
            Button(action: {
                action()
            }) {
                Image(systemName: "arrow.turn.down.right")
            }
            .buttonStyle(.plain)
            
            CommentView(comment, displayControls: false)
                .font(.caption)
            Spacer()
        }
    }
    
    private func cycleMode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch mode {
        case .all:
            self.mode = .collapseAfterOne
        default:
            self.mode = .all
        }
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        VStack {
            CommentView(parent)
            
            switch mode {
                case .all: childrenDisplayModeAll
                case .collapseAfterOne: childrenDisplayModeCollapseAfterOne
                case .collapseAll: childrenDisplayModeCollapseAll
            }
        }
    }
}

// MARK: Views
extension CommentTreeView {
    
    // MARK: Children
    private var childrenDisplayModeAll: some View {
        ForEach(children) { child in
            getViewForChildComment(child, action: cycleMode)
        }
    }
    
    @ViewBuilder
    private var childrenDisplayModeCollapseAfterOne: some View {
        if children.count > 0 {
            getViewForChildComment(children[0], action: cycleMode)
        }
        
        if children.count > 1 {
            getViewForChild(text: "... \(children.count-1) more", action: cycleMode)
                .foregroundStyle(Color.accentColor)
        }
    }
    
    @ViewBuilder
    private var childrenDisplayModeCollapseAll: some View {
        if children.count > 0 {
            getViewForChild(text: "... \(children.count) more", action: {})
                .foregroundStyle(Color.accentColor)
        }
    }
}

// MARK: Previews
#Preview("Display Mode All") {
    let lorem  = MockupUtilities.getShortLorem()
    let lorem2 = MockupUtilities.getShortLorem()
    
    let mockUser = MockupUtilities.getMockUser()
    let mockPost = MockupUtilities.getMockPost(by: mockUser)
    let mockComment = MockupUtilities.getMockComment(by: mockUser, to: mockPost, with: "Parent: \(lorem)")
    let mockReplyToComment = MockupUtilities.getMockComment(by: mockUser, to: mockPost, under: mockComment, with: "Child: \(lorem2)")
    
    return CommentTreeView(mockComment, children: [mockReplyToComment, mockReplyToComment, mockReplyToComment], mode: .all)
}

#Preview("Display Mode Collapsed After One") {
    let lorem  = MockupUtilities.getShortLorem()
    let lorem2 = MockupUtilities.getShortLorem()
    
    let mockUser = MockupUtilities.getMockUser()
    let mockPost = MockupUtilities.getMockPost(by: mockUser)
    let mockComment = MockupUtilities.getMockComment(by: mockUser, to: mockPost, under: nil, with: "Parent: \(lorem)")
    let mockReplyToComment = MockupUtilities.getMockComment(by: mockUser, to: mockPost, under: mockComment, with: "Child: \(lorem2)")
    
    return CommentTreeView(mockComment, children: [mockReplyToComment, mockReplyToComment, mockReplyToComment], mode: .collapseAfterOne)
}
