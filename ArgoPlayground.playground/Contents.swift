//: Playing around with Argo, the json parsing library.

import Argo
import Curry

//: User to decode with Argo.

struct User {
    let userId: Int
    let firstName: String
    let lastName: String
    let email: String?
    let companyName: String
    let friends: [User]?
}

extension User: Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return curry(User.init)
            <^> json <| "id"
            <*> json <| "firstName"
            <*> json <| "lastName"
            <*> json <|? "email"
            <*> json <| "company"
            <*> json <||? "friends"
    }
}

//: Group to decode containing a list of Users.

struct Group {
    let users: [User]
}

extension Group: Decodable {
    static func decode(json: JSON) -> Decoded<Group> {
        return curry(Group.init)
            <^> json <|| "users"
    }
}

//: Setup json objects to play around with.

var georgeJson: AnyObject = [
        "id":1,
        "firstName":"George",
        "lastName":"Washington",
        "email":"email1@gmail.com",
        "company":"Company",
        "friends": [
            [
                "id":2,
                "firstName":"Larry",
                "lastName":"Walker",
                "email":"email2@gmail.com",
                "company":"Company",
                "friends": []
            ],
            [
                "id":3,
                "firstName":"Tom",
                "lastName":"Smith",
                "company":"Company",
                "friends": []
            ]
        ]
    ]

var larryJson: AnyObject = [
    "id":2,
    "firstName":"Larry",
    "lastName":"Walker",
    "email":"email2@gmail.com",
    "company":"Company",
    "friends": [
        [
            "id":1,
            "firstName":"George",
            "lastName":"Washington",
            "email":"email1@gmail.com",
            "company":"Company",
            "friends": []
        ]
    ]
]

var tomJson: AnyObject = [
    "id":3,
    "firstName":"Tom",
    "lastName":"Smith",
    "company":"Company",
    "friends": [
        [
            "id":1,
            "firstName":"George",
            "lastName":"Washington",
            "email":"email1@gmail.com",
            "company":"Company",
            "friends": []
        ]
    ]
]

var invalidJson: AnyObject = [
    "id":3,
    "company":"Company",
    "lastName":"NoFirstName",
    "friends": [
        [
            "id":1,
            "firstName":"George",
            "lastName":"Washington",
            "email":"email1@gmail.com",
            "company":"Company",
            "friends": []
        ]
    ]
]

//: Decode json object nesting in array.

var jsonString: String = "{\"id\":3, \"firstName\":\"Steve\", \"lastName\":\"Macintoch\", \"company\":\"Company\", \"friends\": null}"

let array = Array<AnyObject>(arrayLiteral: georgeJson, larryJson, tomJson)
let json = ["users": array] as AnyObject
if let group: Group = decode(json) {
    group.users[0].userId
    group.users[0].firstName
    group.users[0].lastName
    group.users[0].email
    group.users[0].companyName
    group.users[0].friends

    group.users[1].userId
    group.users[1].firstName
    group.users[1].lastName
    group.users[1].email
    group.users[1].companyName
    group.users[1].friends

    group.users[2].userId
    group.users[2].firstName
    group.users[2].lastName
    group.users[2].email
    group.users[2].companyName
    group.users[2].friends
}

//: Decode single json object.

if let user: User = decode(tomJson) {
    user.userId
    user.firstName
    user.lastName
    user.email
    user.companyName
    user.friends
}

//: Decode child object of jsonDictionary.

let tomsFriends = tomJson["friends"] as! [AnyObject]

if let user: User = decode(tomsFriends[0]) {
    user.userId
    user.firstName
    user.lastName
    user.email
    user.companyName
    user.friends
}

//: Try out mapping result of Decoding.

let validUser: Decoded<User> = decode(tomJson)
validUser.map({ (user) -> String in
    return user.firstName + " " + user.lastName
})

let invalidUser: Decoded<User> = decode(invalidJson)
invalidUser.map({ (user) -> String in
    return user.firstName + " " + user.lastName
})
