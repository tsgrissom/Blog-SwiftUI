import Combine
import Foundation
import SwiftUI
import SwiftData

final class UserAccountManager: ObservableObject {
    
    private let currentUserKey = "LoggedInUser"
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
        defaults.removeObject(forKey: currentUserKey)
        print("Cleared current session UserAccount")
    }
    
    public func setUserForSession(_ user: UserAccount?) {
        if user == nil {
            print("Could not set session UserAccount to nil")
            return
        }
        
        loggedInUser = user
        defaults.setValue(user!.id, forKey: currentUserKey)
        print("Logged in as \(user!.username)")
    }
}
