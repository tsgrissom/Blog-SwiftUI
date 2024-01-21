import Foundation
import LoremSwiftum

struct MockupUtilities {
    
    static func getMockUsername(
        first: String = LoremSwiftum.Lorem.firstName,
        last: String  = LoremSwiftum.Lorem.lastName
    ) -> String {
        var username = "\(first)\(last)"
        
        if Bool.random() { // With numbers
            for _ in 1...4 {
                let random = Int.random(in: 0...9)
                username += "\(random)"
            }
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
    
    static func getMockPost(by: UserAccount = getMockUser()) -> Post {
        let post = Post(body: getLongLorem(), postedBy: by)
        return post
    }
    
    static func getMockComment(
        by postedBy: UserAccount = getMockUser(),
        to attachedTo: Post = getMockPost(),
        under parent: PostComment? = nil,
        with body: String = getShortLorem()
    ) -> PostComment {
        let comment = PostComment(body: body, postedBy: postedBy, attachedTo: attachedTo, parentComment: parent)
        return comment
    }
}
