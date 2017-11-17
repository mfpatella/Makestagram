//
//  DatabaseReference+Location.swift
//  Makestagram
//
//  Created by Matthew Patella on 11/14/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension DatabaseReference {
    
    enum MGLocation {
        
        case root
        
        case posts(uid: String)
        case showPost(posterUID: String, postKey: String)
        case newPost(currentUID: String)
        
        case users
        case showUser(uid: String)
        case timeline(uid: String)
        
        case followers(uid: String)
        
        case likes(postKey: String, currentUID: String)
        case isLiked(postKey: String)
        case likesCount(posterUID: String, postKey: String)
        
        
        func asDatabaseReference() -> DatabaseReference {
            
            let root = Database.database().reference()
            
            switch self {
            case .root:
                return root
                
            case .posts(let uid):
                return root.child("posts").child(uid)
                
            case .showPost(let posterUID, let postKey):
                return root.child("posts").child(posterUID).child(postKey)
                
            case .newPost(let currentUID):
                return root.child("posts").child(currentUID).childByAutoId()
                
            case .users:
                return root.child("users")
                
            case .showUser(let uid):
                return root.child("users").child(uid)
                
            case .timeline(let uid):
                return root.child("timeline").child(uid)
                
            case .followers(let uid):
                return root.child("followers").child(uid)
                
            case .likes(let postKey, let currentUID):
                return root.child("postLikes").child(postKey).child(currentUID)
                
            case .isLiked(let postKey):
                return root.child("postLikes/\(postKey)")
                
            case .likesCount(let posterUID, let postKey):
                return root.child("posts").child(posterUID).child(postKey).child("likes_count")
                
            }
        }
    }
    
    static func toLocation(_ location: MGLocation) -> DatabaseReference {
        
        return location.asDatabaseReference()
    }
}
