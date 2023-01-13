//
//  User.swift
//  InstagramClone
//
//  Created by admin on 28.12.2022.
//
import FirebaseAuth
import FirebaseDatabase
import Firebase

class User{
    
    // attributes
    var username:String!
    var name: String!
    var profileImageURL: String!
    var uid: String!
    var isFollowed = false
    
    init(uid:String, dictionary: Dictionary<String, AnyObject>){
        self.uid = uid
        if let username = dictionary["username"] as? String,
           let name = dictionary["name"] as? String,
           let profileImageURL = dictionary["profileImageURL"] as? String{
            self.username = username
            self.name = name
            self.profileImageURL = profileImageURL
        }
    }
    
    func follow(){
        guard let currentUid = Auth.auth().currentUser?.uid else{ return }

        guard let uid = uid else { return }

        // set isFollowed true
        self.isFollowed = true
        
        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
        // add followed users posts to current user-feed
        USER_FEED_REF.child(uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
        
    }
    
    func unfollow(){
        guard let currentUid = Auth.auth().currentUser?.uid else{ return }
        guard let uid = uid else { return } 
        // set isFollowed false
        self.isFollowed = false
        
        // remove user from current user-following structure
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        // remove current user from user-follower structure
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        // remove unfollowed users posts from current user-feed
        USER_POSTS_REF.child(self.uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }

    }
    func checkIfUserIsFollowed(completion: @escaping(Bool) -> ()){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
}
