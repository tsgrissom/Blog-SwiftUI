import SwiftUI
import SwiftData

enum UserModifyProfileMode {
    case biography
    case displayName
    case username
}

struct UserModifyProfileFieldView: View {
    
    // MARK: Environment
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    @EnvironmentObject
    private var accountManager: UserAccountManager
    
    // MARK: SwiftData Queries
    @Query
    private var users: [UserAccount]
    
    // MARK: Initialization
    private let mode: UserModifyProfileMode
    
    init(mode: UserModifyProfileMode) {
        self.mode = mode
        loadCurrents()
    }
    
    // MARK: Load
    private func loadCurrents() {
        let currentUser = users.first { $0.id == accountManager.loggedInUser?.id }
        let currentValue = switch mode {
            case .biography: currentUser?.biography
            case .displayName: currentUser?.displayName
            case .username: currentUser?.username
        }
        
        fieldContents = currentValue ?? ""
        fieldContentsOriginal = currentValue ?? ""
    }
    
    // MARK: State
    /*
     * 0=Default
     * 1=Error
     * 2=Success
     */
    @State
    private var buttonSubmitAnimate = 0
    @State
    private var fieldContents = ""
    @State
    private var fieldContentsOriginal = ""
    
    @FocusState
    private var isFieldFocused: Bool
    
    // MARK: Helpers
    private func flashAlert(_ text: String = "Cannot modify your profile") {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    // MARK: Button Handlers
    private func onSubmit() {
        func flashButtonFeedback(_ animateTo: Int = 1) {
            buttonSubmitAnimate = animateTo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                buttonSubmitAnimate = 0
            }
        }
        
        if accountManager.isNotLoggedIn {
            flashAlert()
            flashButtonFeedback()
            return
        }
        
        let text = fieldContents.trimmed
        
        if text.isEmpty {
            flashAlert()
            flashButtonFeedback()
            return
        }
        
        let user = users.first { $0.id == accountManager.loggedInUser?.id }
        
        if user == nil {
            flashAlert()
            flashButtonFeedback()
            return
        }
        
        flashButtonFeedback(2)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        switch mode {
            case .biography: user?.biography = text
            case .displayName: user?.displayName = text
            case .username: user?.username = text
        }
        
        try? modelContext.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
            dismiss()
        }
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        let noun = switch mode {
            case .biography: "Biography"
            case .displayName: "Name"
            case .username: "Username"
        }
        
        return NavigationStack {
            VStack {
    //            if accountManager.isNotLoggedIn {
    //                AccountNotLoggedInView()
    //            } else {
                    rowForm
                    .padding(.top, 10)
    //            }
                Spacer()
            }
            .navigationTitle("Changing \(noun)")
            .padding(.horizontal)
            .buttonStyle(.bordered)
            .textFieldStyle(.roundedBorder)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isFieldFocused = true
                }
            }
        }
    }
}

// MARK: Views
extension UserModifyProfileFieldView {
    
    // MARK: Buttons
    private var isButtonSubmitDisabled: Bool {
        return fieldContents.trimmed.isEmpty
    }
    
    private var buttonSubmitSymbol: String {
        return switch buttonSubmitAnimate {
            case 1: "xmark"
            default: "checkmark"
        }
    }
    
    private var buttonSubmit: some View {
        let tint: Color = switch buttonSubmitAnimate {
            case 1: .red
            case 2: .green
            default: .gray
        }
        
        return Button(action: onSubmit) {
            Image(systemName: buttonSubmitSymbol)
        }
        .disabled(isButtonSubmitDisabled)
        .tint(tint)
    }
    
    private var buttonKeyboardSubmit: some View {
        let tint: Color = switch buttonSubmitAnimate {
            case 1: .red
            case 2: .green
            default: .primary
        }
        
        return Button(action: onSubmit) {
            Image(systemName: buttonSubmitSymbol)
        }
        .buttonStyle(.plain)
        .foregroundStyle(tint)
        .disabled(isButtonSubmitDisabled)
    }
    
    private var buttonKeyboardErase: some View {
        func onPress() {
            fieldContents = ""
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        var isDisabled: Bool {
            return fieldContents.isEmpty
        }
        
        return Button(action: onPress) {
            Image(systemName: "eraser")
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
    
    private var buttonKeyboardRestore: some View {
        func onPress() {
            fieldContents = fieldContentsOriginal
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        var isDisabled: Bool {
            return fieldContents == fieldContentsOriginal
        }
        
        return Button(action: onPress) {
            Image(systemName: "arrow.counterclockwise")
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
    
    private var buttonKeyboardDismiss: some View {
        func onPress() {
            isFieldFocused = false
        }
        
        return Button(action: onPress) {
            Image(systemName: "keyboard.chevron.compact.down")
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Text Fields
    private var fieldBiography: some View {
        let noun = switch mode {
            case .biography: "biography"
            case .displayName: "display name"
            case .username: "username"
        }
        
        return TextField(text: $fieldContents, prompt: Text("Enter your new \(noun)")) {
            Text("Enter your new \(noun)")
        }
        .focused($isFieldFocused)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                buttonKeyboardSubmit
                buttonKeyboardRestore
                buttonKeyboardErase
                buttonKeyboardDismiss
            }
        }
    }
    
    // MARK: Rows + Sections
    private var rowForm: some View {
        return HStack {
            fieldBiography
            buttonSubmit
        }
    }
}

// MARK: Previews
#Preview("Biography") {
    UserModifyProfileFieldView(mode: .biography)
        .environmentObject(UserAccountManager())
}

#Preview("Display Name") {
    UserModifyProfileFieldView(mode: .displayName)
        .environmentObject(UserAccountManager())
}
