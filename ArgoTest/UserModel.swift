//
//  UserModel.swift
//  ArgoTest
//
//  Created by ノーランワーナー on 2015/12/22.
//  Copyright © 2015年 test. All rights reserved.
//

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
