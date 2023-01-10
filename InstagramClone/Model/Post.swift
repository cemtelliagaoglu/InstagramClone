//
//  Post.swift
//  InstagramClone
//
//  Created by admin on 11.01.2023.
//

import Foundation

class Post{
    
    var caption: String!
    var likes: Int!
    var imageURL: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    
    init(postId: String, dictionary: Dictionary<String,AnyObject>){
        
        self.postId = postId
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
    
}
