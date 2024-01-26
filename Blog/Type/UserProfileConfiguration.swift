//
//  UserProfileConfiguration.swift
//  Blog
//
//  Created by Tyler Grissom on 1/25/24.
//

import Foundation
import SwiftUI
import SwiftData

class UserProfileConfiguration: ObservableObject {
    
    @Environment(\.modelContext)
    private var modelContext
    
    private let user: UserAccount
    
    init(user: UserAccount) {
        self.user = user
    }
    
    public var biography: String {
        get {
            return user.biography
        }
        
        set {
            user.biography = newValue
        }
    }
}
