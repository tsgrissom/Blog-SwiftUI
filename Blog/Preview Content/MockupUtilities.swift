import Foundation
import LoremSwiftum

struct MockupUtilities {
    
    static func getMockUsername(
        first: String = LoremSwiftum.Lorem.firstName,
        last: String  = LoremSwiftum.Lorem.lastName
    ) -> String {
        var username = "\(first)\(last)"
        
        if Bool.random() { // With numbers
            username += "4337"
        }
        
        return username
    }
    
    static func getMockNames(
        first: String = LoremSwiftum.Lorem.firstName,
        last: String = LoremSwiftum.Lorem.lastName
    ) -> (username: String, displayName: String) {
        let username = getMockUsername(first: first, last: last)
        let displayName = "\(first) \(last)"
        
        return (username, displayName)
    }
    
    static func getMockUser() -> UserAccount {
        let names = getMockNames()
        let user  = UserAccount(
            username: names.username,
            password: "Password"
        )
        
        user.displayName = names.displayName
        
        return user
    }
    
    static func getShortLorem() -> String {
        return LoremSwiftum.Lorem.shortTweet
    }
    
    static func getLongLorem() -> String {
        return LoremSwiftum.Lorem.tweet
    }
}
