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
    }
    
    // MARK: State
    @State
    private var alertOffset: CGSize = .zero
    @State
    private var alertText = "Something went wrong"
    @State
    private var alertVisible = false
    
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
    private var fieldIsFocused: Bool
    
    // MARK: Helpers
    private func flashAlert(_ text: String = "Cannot modify your profile") {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        
        withAnimation {
            alertVisible = true
        }
        alertText = text
    }
    
    // MARK: Data Functions
    private func loadInternalValue() {
        self.fieldContentsOriginal = switch mode {
            case .biography:
                accountManager.loggedInUser?.biography ?? ""
            case .displayName:
                accountManager.loggedInUser?.displayName ?? ""
            case .username:
                accountManager.loggedInUser?.username ?? ""
        }
        self.fieldContents = fieldContentsOriginal
    }
    
    private func updateInternalValue() {
        let user = users.first { $0.id == accountManager.loggedInUser?.id }
        let text = fieldContents.trimmed
        
        switch mode {
            case .biography:
                user?.biography = text
            case .displayName:
                user?.displayName = text
            case .username:
                user?.username = text
        }
        
        try? modelContext.save()
    }
    
    // MARK: Button Handlers
    private func onSubmit() {
        func flashButtonFeedback(_ animateTo: Int = 1) {
            buttonSubmitAnimate = animateTo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                buttonSubmitAnimate = 0
            }
        }
        
        // Check state
        if accountManager.isNotLoggedIn {
            flashAlert("You are not logged in")
            flashButtonFeedback()
            return
        }
        
        let text = fieldContents.trimmed
        let thing = switch mode {
            case .biography: "bio"
            case .displayName: "display name"
            case .username: "username"
        }
        
        if text.isEmpty {
            flashAlert("Your \(thing) cannot be empty")
            flashButtonFeedback()
            return
        }
        
        let user = users.first { $0.id == accountManager.loggedInUser?.id }
        
        if user == nil {
            flashAlert("You must be logged in")
            flashButtonFeedback()
            return
        }
        
        // Lint specific value type
        if mode == .biography {
            if text.count > 140 {
                flashAlert("Bio cannot be more than 140 characters (was \(text.count))")
                flashButtonFeedback()
                return
            }
            
        } else if mode == .displayName {
            if text.count > 24 {
                flashAlert("Display name cannot be more than 24 characters (was \(text.count))")
                flashButtonFeedback()
                return
            }
            
            
        } else if mode == .username {
            if text.contains(" ") {
                flashAlert("Username cannot contain whitespace")
                flashButtonFeedback()
                return
            }
            
        }
        
        flashButtonFeedback(2)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        updateInternalValue()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
            dismiss()
        }
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        let noun = switch mode {
            case .biography: "Bio"
            case .displayName: "Name"
            case .username: "Username"
        }
        
        return NavigationStack {
            VStack {
                if accountManager.isNotLoggedIn {
                    AccountNotLoggedInView()
                        .padding(.top, 10)
                } else {
                    rowForm
                        .padding(.top, 10)
                }
                
                if alertVisible {
                    sectionAlert
                        .padding(.top, 10)
                }
                
                Spacer()
            }
            .navigationTitle("Changing \(noun)")
            .padding(.horizontal)
            .buttonStyle(.bordered)
            .textFieldStyle(.roundedBorder)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                    loadInternalValue()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    fieldIsFocused = true
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
    
    // MARK: Toolbar Buttons
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
            fieldIsFocused = false
        }
        
        return Button(action: onPress) {
            Image(systemName: "keyboard.chevron.compact.down")
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Text Fields
    private var fieldModifyValue: some View {
        let noun = switch mode {
            case .biography: "biography"
            case .displayName: "display name"
            case .username: "username"
        }
        
        return TextField(text: $fieldContents, prompt: Text("Enter your new \(noun)")) {
            Text("Enter your new \(noun)")
        }
        .focused($fieldIsFocused)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                buttonKeyboardSubmit
                buttonKeyboardRestore
                buttonKeyboardErase
                buttonKeyboardDismiss
            }
        }
        .onSubmit {
            onSubmit()
        }
    }
    
    // MARK: Rows + Sections
    private var rowForm: some View {
        return HStack {
            fieldModifyValue
            buttonSubmit
        }
    }
    
    private var sectionAlert: some View {
        let offsetHt = alertOffset.height
        let modifiedY: CGFloat = if offsetHt >= 0 {
            offsetHt > 10.0 ? 10.0 : offsetHt
        } else {
            offsetHt < -10.0 ? -10.0 : offsetHt
        }
        
        return ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.red)
                .padding(.horizontal)
            VStack {
                Text(alertText)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
            }
        }
        .frame(minHeight: 35)
        .frame(maxHeight: 55)
        .transition(.move(edge: alertOffset.width <= 0 ? .leading : .trailing))
        .offset(x: alertOffset.width, y: modifiedY)
        .onTapGesture {
            withAnimation {
                alertVisible = false
            }
        }
        .gesture(
            DragGesture()
                .onChanged { drag in
                    alertOffset = drag.translation
                }
                .onEnded { drag in
                    if drag.translation.width > 100.0 || drag.translation.width < -100.0 {
                        withAnimation {
                            alertVisible = false
                        } completion: {
                            alertOffset = .zero
                        }
                    } else {
                        withAnimation {
                            alertOffset = .zero
                        }
                    }
                }
        )
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
