//
//  Post.swift
//  InstagramClone
//
//  Created by admin on 11.01.2023.
//

import Foundation
import Firebase

class Post{
    
    var caption: String!
    var likes: Int!
    var imageURL: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false
    
    init(postId: String,user: User, dictionary: Dictionary<String,AnyObject>){
        
        self.postId = postId
        self.user = user
        
        if let caption = dictionary["caption"] as? String{
            self.caption = caption
        }
        if let likes = dictionary["likes"] as? Int{
            self.likes = likes
        }
        
        if let imageURL = dictionary["imageURL"] as? String{
            self.imageURL = imageURL
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String{
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double{
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let postId = dictionary["postId"] as? String{
            self.postId = postId
        }

    }
    
    func adjustLikes(addLike:Bool, completion: @escaping(Int) -> ()){
        
        guard let currentUid = Auth.auth().currentUser?.uid else{ return }
        guard let postId = self.postId else{ return }
        
        if addLike{
            // updates user-likes structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1]) { (err, ref) in
                
                //updates post-likes structure
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1]) { err, ref in
                    self.likes += 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                }
            }
        }else{
            // remove like from user-likes structure
            USER_LIKES_REF.child(currentUid).removeValue { err, ref in
                // remove like from post-likes structure
                POST_LIKES_REF.child(self.postId).removeValue { err, ref in
                    guard self.likes > 0 else{ return }
                    self.likes -= 1
                    self.didLike = false
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                }
            }
            
        }
    }
    
}
