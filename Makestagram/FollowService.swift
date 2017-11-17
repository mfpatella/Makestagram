//
//  FollowService.swift
//  Makestagram
//
//  Created by Matthew Patella on 10/25/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
    
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)": true,
                          "following/\(user.uid)/\(currentUID)": true]
        
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            UserService.posts(for: user) { (posts) in
                
                let postKeys = posts.flatMap { $0.key }
                
                var followData = [String: Any]()
                let timelinePostDict = ["poster_uid" : user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                        success(error == nil)
                })
                
            }
        }
    }
    
    private static func unFollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)": NSNull(),
                          "following/\(user.uid)/\(currentUID)": NSNull()]
        
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            UserService.posts(for: user) { (posts) in
                
                let postKeys = posts.flatMap { $0.key }
                
                var unfollowData = [String: Any]()
                
                postKeys.forEach { unfollowData["timeline/\(currentUID)/\($0)"] = NSNull() }
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    success(error == nil)
                })
            }
        }
    }
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unFollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    static func isFollowing(_ followingUser: User, completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followingUserUID = followingUser.uid
        
        let followersRef = Database.database().reference().child("followers").child(followingUserUID)
        followersRef.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String: Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
}
