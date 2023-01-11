//
//  Database.swift
//  InstagramClone
//
//  Created by admin on 6.01.2023.
//

import Foundation
import Firebase

extension Database{
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()){
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let userDict = snapshot.value as? Dictionary<String,AnyObject> else{ return }
            
            let user = User(uid: uid, dictionary: userDict)
            
            completion(user)
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()){
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? Dictionary<String,AnyObject> else{ return }
            guard let ownerUid = dictionary["ownerUid"] as? String else{ return }
            
            Database.fetchUser(with: ownerUid) { user in
                
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                
                completion(post)
            }
        }
    }
    
}

