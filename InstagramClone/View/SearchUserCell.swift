//
//  SearchUserCell.swift
//  InstagramClone
//
//  Created by admin on 30.12.2022.
//

import UIKit

class SearchUserCell: UITableViewCell {
    //MARK: - Properties
    
    var user: User?{
        didSet{
            guard let username = user?.username,
                  let fullName = user?.name,
                  let profileImageURL = user?.profileImageURL else{ return }
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullName
            self.profileImageView.loadImage(with: profileImageURL)
            
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        // add profile image view
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.clipsToBounds = true
        
        self.textLabel?.text = "Username"
        self.detailTextLabel?.text = "Full Name"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: (textLabel?.frame.origin.y)! - 2,
                                  width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = .boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y,
                                        width: self.frame.width - 108 , height: (detailTextLabel!.frame.height))
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = .systemFont(ofSize: 12)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
