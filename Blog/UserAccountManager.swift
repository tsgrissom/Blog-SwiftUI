import Combine
import Foundation
import SwiftUI
import SwiftData

final class UserAccountManager: ObservableObject {
    
    private let defaults = UserDefaults.standard
    
    @Published
    public var loggedInUser: UserAccount? = nil
    
    public var loggedInUsernameOrNone: String {
        return if loggedInUser != nil {
            loggedInUser?.username ?? "None"
        } else {
            "None"
        }
    }
    
    public var isLoggedIn: Bool {
        return loggedInUser != nil
    }
    
    public var isNotLoggedIn: Bool {
        return !isLoggedIn
    }
    
    public func clearUserForSession() {
        loggedInUser = nil
        defaults.removeObject(forKey: "LoggedInUser")
        print("Cleared Default User")
    }
    
    public func setUserForSession(_ user: UserAccount) {
        loggedInUser = user
        defaults.setValue(user.username, forKey: "LoggedInUser")
        print("Default User set to \"\(user.username)\"")
    }
}
