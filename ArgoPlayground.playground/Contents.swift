//: Playing around with Argo, the json parsing library.

import Argo
import Curry

struct UserList {
    let users: [User]
}

extension UserList: Decodable {
    static func decode(json: JSON) -> Decoded<UserList> {
        return curry(UserList.init)
            <^> json <|| "users"
    }
}

struct User {
    let userId: Int
    let name: String
    let email: String?
    let companyName: String
    let friends: [User]?
}

extension User: Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return curry(User.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <|? "email" // Use ? for parsing optional values
            <*> json <| "company" // Parse nested objects
            <*> json <||? "friends" // parse arrays of objects
    }
}

var georgeJson: AnyObject {
    return [
        "id":1,
        "name":"George",
        "email":"email1@gmail.com",
        "company":"Company",
        "friends": [
            [
                "id":2,
                "name":"Larry",
                "email":"email2@gmail.com",
                "company":"Company",
                "friends": []
            ],
            [
                "id":3,
                "name":"Tom",
                "company":"Company",
                "friends": []
            ]
        ]
    ]
}

var larryJson: AnyObject {
    return [
        "id":2,
        "name":"Larry",
        "email":"email2@gmail.com",
        "company":"Company",
        "friends": [
            [
                "id":1,
                "name":"George",
                "email":"email1@gmail.com",
                "company":"Company",
                "friends": []
            ]/*,
            [
            "id":3,
            "name":"Tom",
            "company":"Company",
            "friends": []
            ]*/
        ]
    ]
}

var tomJson: AnyObject {
    return [
        "id":3,
        "name":"Tom",
        "company":"Company",
        "friends": [
            [
                "id":1,
                "name":"George",
                "email":"email1@gmail.com",
                "company":"Company",
                "friends": []
            ]/*,
            [
            "id":2,
            "name":"Larry",
            "email":"email2@gmail.com",
            "company":"Company",
            "friends": []
            ]*/
        ]
    ]
}

var invalidJson: AnyObject {
    return [
        "id":3,
        "company":"Company",
        "friends": [
            [
                "id":1,
                "name":"George",
                "email":"email1@gmail.com",
                "company":"Company",
                "friends": []
            ]
        ]
    ]
}



var jsonString: String {
    return " {\"id\":3, \"name\":\"Steve\", \"company\":\"Company\", \"friends\": null } "
}

func jsonManipulationWithStrings() {
    guard
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
        let json: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
            print("Invalid json string.")
            return
    }
    
    print("The Json:")
    print(json)
    
    if let user: Decoded<User> = decode(json) {
        print("****")
        print(user)
    }
}

func jsonManipulationWithDicts() {
    let array = Array<AnyObject>(arrayLiteral: georgeJson, larryJson, tomJson)
    let json = ["users": array] as AnyObject
    if let userList: UserList = decode(json) {
        print("****")
        for user in userList.users {
            printUser(user)
        }
    }
    
    if let user: User = decode(tomJson) {
        print("****")
        printUser(user)
    }
    
    let tomsFriends = tomJson["friends"] as! [AnyObject]
    print("****")
    for tomsFriend in tomsFriends {
        if let friend: User = decode(tomsFriend) {
            printUser(friend)
        }
    }
    
    let invalidUser: Decoded<User> = decode(invalidJson)
    let invalidName = invalidUser.map({ (user) -> String in
        return user.name
    })
    print("****")
    print(invalidName)
    
    let validUser: Decoded<User> = decode(tomJson)
    let validName = validUser.map({ (user) -> String in
        return user.name
    })
    print("****")
    print(validName)
}

func printUser(user: User) {
    print("====")
    print(user.userId)
    print(user.name)
    if let email = user.email {
        print(email)
    }
    print(user.companyName)
    
    guard let friends = user.friends else {
        print("Friend Count: 0")
        return
    }
    
    print("Friend Count: \(friends.count)")
    
    for friend in friends {
        print("    ----")
        print("    \(friend.userId)")
        print("    " + friend.name)
        if let email = friend.email {
            print("    " + email)
        }
        print("    " + friend.companyName)
    }
}

jsonManipulationWithStrings()
jsonManipulationWithDicts()