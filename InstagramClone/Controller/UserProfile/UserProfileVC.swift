//
//  UserProfileVC.swift
//  InstagramClone
//
//  Created by admin on 24.12.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //MARK: - Properties
    
    var user: User?
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        //background color
        self.view.backgroundColor = .lightGray
        self.collectionView.backgroundColor = .white
        // fetch user data
        if self.user == nil{
            fetchCurrentUserData()
        }
        
        // fetch posts
        fetchPosts()
    }
    //MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    // MARK: - UICollectionView
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        // set delegate
        header.delegate = self
        // set the user in header
        header.user = self.user
        navigationItem.title = self.user?.username
        // return header
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        // Configure the cell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.viewSinglePost = true
        feedVC.post = self.posts[indexPath.row]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    //MARK: - API
    func fetchPosts(){
        
        var uid: String!
        if let user = self.user{
            uid = user.uid
        }else{
            uid = Auth.auth().currentUser?.uid
        }
        
        USER_POSTS_REF.child(uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { post in
                
                self.posts.append(post)
                self.posts.sort(by: {$0.creationDate > $1.creationDate})
                
                self.collectionView.reloadData()
            }
        }
        
    }
    func fetchCurrentUserData(){
        
        guard let currentUid = Auth.auth().currentUser?.uid else{ fatalError() }
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary< String, AnyObject> else{ return }
            let user = User(uid: currentUid, dictionary: dictionary)
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }
}

//MARK: - UserProfileHeaderDelegate Methods
extension UserProfileVC: UserProfileHeaderDelegate{
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    
    func setUserStats(for header: UserProfileHeader) {
        
        guard let uid = header.user?.uid else{ return }
        
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        // get number of follower
        USER_FOLLOWER_REF.child(uid).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject>{
                numberOfFollowers = snapshot.count
            }else{
                numberOfFollowers = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "followers",attributes: [.font: UIFont.systemFont(ofSize: 14),.foregroundColor: UIColor.lightGray]))
            header.followersLabel.attributedText = attributedString
        }
        
        
        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { snapshot  in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject>{
                numberOfFollowing = snapshot.count
            }else{
                numberOfFollowing = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "following",attributes: [.font: UIFont.systemFont(ofSize: 14),.foregroundColor: UIColor.lightGray]))
            header.followingLabel.attributedText = attributedString
        }

        
    }
    
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        guard let user = header.user else{ return }
        if header.editProfileFollowButton.titleLabel?.text == "Follow"{
            user.follow()
            header.editProfileFollowButton.setTitle("Following", for: .normal)
        }else{
            user.unfollow()
            header.editProfileFollowButton.setTitle("Follow", for: .normal)
        }
    }
    
}
