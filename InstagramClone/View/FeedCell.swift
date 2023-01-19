//
//  FeedCell.swift
//  InstagramClone
//
//  Created by admin on 11.01.2023.
//

import UIKit
import Firebase

class FeedCell: UICollectionViewCell{
    //MARK: - Properties
    
    var delegate: FeedCellDelegate?
    
    var post: Post? {
        didSet{
            guard let ownerUid = post?.ownerUid else { return }
            guard let imageURL = post?.imageURL else{ return }
            guard let likes = post?.likes else{ return }
            Database.fetchUser(with: ownerUid) { user in
                self.profileImageView.loadImage(with: user.profileImageURL)
                self.usernameButton.setTitle(user.username, for: .normal)
                self.configurePostCaption(user: user)
            }
            
            self.postImageView.loadImage(with: imageURL)
            
            self.likesLabel.text = "\(likes) likes"
            configureLikeButton()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("username", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()
    
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "send2"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var savePostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.text = "3 likes"
        // add gesture recognizer
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        
        var attributedText = NSMutableAttributedString(string: "username", attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " some test caption", attributes: [.font: UIFont.systemFont(ofSize: 12)]))
        label.attributedText = attributedText
        return label
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 10)
        label.text = "2 days ago"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(usernameButton)
        usernameButton.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(optionsButton)
        optionsButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureActionButtons()
        
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Configuration
    func configurePostCaption(user: User){
        
        guard let caption = post?.caption else{ return }
        
        let attributedText = NSMutableAttributedString(string: user.username, attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " \(caption)", attributes: [.font: UIFont.systemFont(ofSize: 12)]))
        captionLabel.attributedText = attributedText
    }
    
    func configureActionButtons(){
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        addSubview(savePostButton)
        savePostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 24)
        
    }
    
    //MARK: - Handler
    @objc func handleUsernameTapped(){
        delegate?.handleUsernameTapped(for: self)
    }
    @objc func handleOptionsTapped(){
        delegate?.handleOptionsTapped(for: self)
    }
    @objc func handleCommentTapped(){
        delegate?.handleCommentTapped(for: self)
    }
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(for: self)
    }
    @objc func handleShowLikes(){
        delegate?.handleShowLikes(for: self)
    }
    func configureLikeButton(){
        delegate?.handleConfigureLikeButton(for: self)
    }
    
}
