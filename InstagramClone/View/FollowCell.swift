//
//  FollowCell.swift
//  InstagramClone
//
//  Created by admin on 2.01.2023.
//

import UIKit
import FirebaseAuth

class FollowCell: UITableViewCell {
    
    //MARK: - Properties
    
    var delegate: FollowCellDelegate?
    
    var user: User?{
        didSet{
            guard let username = user?.username,
                  let fullName = user?.name,
                  let profileImageURL = user?.profileImageURL else{ return }
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullName
            self.profileImageView.loadImage(with: profileImageURL)
            
            // hide follow button for current user
            if user?.uid == Auth.auth().currentUser?.uid{
                followButton.isHidden = true
            }
            
            user?.checkIfUserIsFollowed(completion: { followed in
                if followed{
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.backgroundColor = .white
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                }else{
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                    
                }
            })
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        
        return button
    }()
    
    
    //MARK: - Handlers
    @objc func handleFollowTapped(){
        delegate?.handleFollowTapped(for: self)
    }
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.clipsToBounds = true
        
        addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 3
        
        self.textLabel?.text = "Username"
        self.detailTextLabel?.text = "Full Name"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}