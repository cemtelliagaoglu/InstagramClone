//
//  UserPostCell.swift
//  InstagramClone
//
//  Created by admin on 11.01.2023.
//

import UIKit

class UserPostCell: UICollectionViewCell {
 
    //MARK: - Properties
    
    var post:Post?{
        didSet{
            guard let imageURL = post?.imageURL else{ return }
            postImageView.loadImage(with: imageURL)
        }
    }
    
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
