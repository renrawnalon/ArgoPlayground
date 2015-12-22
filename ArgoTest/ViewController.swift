//
//  ViewController.swift
//  ArgoTest
//
//  Created by ノーランワーナー on 2015/12/22.
//  Copyright © 2015年 test. All rights reserved.
//

import UIKit
import Argo

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let array = Array<AnyObject>(arrayLiteral: georgeJson, larryJson, tomJson)
        let json = ["users": array] as AnyObject
        if let userList: UserList = decode(json) {
            print("success")
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
    }
    
    func printUser(user: User) {
        print("====")
        print(user.userId)
        print(user.name)
        if let email = user.email {
            print(email)
        }
        print(user.companyName)
        print("Friend Count: \(user.friends.count)")
        
        for friend in user.friends {
            print("    ----")
            print("    \(friend.userId)")
            print("    " + friend.name)
            if let email = friend.email {
                print("    " + email)
            }
            print("    " + friend.companyName)
        }
    }
    
    var georgeJson: AnyObject {
        let json = [
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
        
        return json
    }
    
    var larryJson: AnyObject {
        let json = [
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
        
        return json
    }
    
    var tomJson: AnyObject {
        let json = [
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
        
        return json
    }
}
