//
//  UserService.swift
//  Makestagram
//
//  Created by Matthew Patella on 10/8/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase


struct UserService {
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?)
    -> Void)
    {
        let userAttrs: [String: Any] = ["username": username,
                         "follower_count": 0,
                         "following_count": 0,
                         "post_count": 0]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil) }
            completion(user) } )
    }
    
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        
        let ref = DatabaseReference.toLocation(.posts(uid: user.uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] = snapshot.reversed().flatMap {
                guard let post = Post(snapshot: $0)
                    else { return nil }
                dispatchGroup.enter()
                
                LikeService.isPostLiked(post) { (isLiked) in
                    post.isLiked = isLiked
                    dispatchGroup.leave()
                }
                
                return post
                
            }
            dispatchGroup.notify(queue: .main, execute: { completion(posts)
                
            })
        
        })
    }
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let users = snapshot.flatMap(User.init).filter { $0.uid != currentUser.uid }
            
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                
                FollowService.isFollowing(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
                    
            }
            
                dispatchGroup.notify(queue: .main, execute: {
                    completion(users)
                })
            })
            
            
    }
    
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        
        let followersRef = Database.database().reference().child("followers").child(user.uid)
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String: Bool]
                else { return completion([]) }
            let followerKeys = Array(followersDict.keys)
            completion(followerKeys)
        })
    }
    
    static func timeline(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([Post]) -> Void) {
        
        let currentUser = User.current
        let ref = DatabaseReference.toLocation(.timeline(uid: currentUser.uid))
        var query = ref.queryOrderedByKey().queryLimited(toLast: pageSize)
        if let lastPostKey = lastPostKey {
            query = query.queryEnding(atValue: lastPostKey)
        }
        
        //let timelineRef = Database.database().reference().child("timeline").child(currentUser.uid)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String: Any],
                let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()
                
                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts.reversed())
                
            })
        })
    }
    
    static func observeProfile(for user: User, completion: @escaping (DatabaseReference, User?,[Post]) -> Void) -> DatabaseHandle {
        
        let userRef = Database.database().reference().child("users").child(user.uid)
        
        return userRef.observe(.value, with: { snapshot in
            
            guard let user = User(snapshot: snapshot) else {
                return completion(userRef, nil, [])
            }
            
            posts(for: user, completion: { posts in
                
                completion(userRef, user, posts)
            })
            
        })
    }
    
    static func following(for user: User = User.current, completion: @escaping ([User]) -> Void) {
        
        let followingRef = Database.database().reference().child("following").child(user.uid)
        
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let followingDict = snapshot.value as? [String : Bool] else
                { return completion([])
                    
            }
            
            var following = [User]()
            let dispatchGroup = DispatchGroup()
            
            for uid in followingDict.keys {
                dispatchGroup.enter()
                
                show(forUID: uid) { user in
                    if let user = user {
                        following.append(user)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(following)
            }
        })
    }
    
    static func observeChats(for user: User = User.current, withCompletion completion: @escaping (DatabaseReference, [Chat]) -> Void) -> DatabaseHandle {
        
        let ref = Database.database().reference().child("chats").child(user.uid)
        
        return ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(ref, [])
            }
            
            let chats = snapshot.flatMap(Chat.init)
            completion(ref, chats)
        })
    }
}
