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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        //background color
        self.view.backgroundColor = .lightGray
        self.collectionView.backgroundColor = .white
        // fetch user data
        if self.user == nil{
            fetchCurrentUserData()
        }

    }
    
//    private func setupLayout(){
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil , right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 200)
//    }
    
   
    // MARK: - UICollectionView
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        // Configure the cell
        
        return cell
    }
    
    //MARK: - API
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
        let followVC = FollowVC()
        followVC.viewFollowers = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowVC()
        followVC.viewFollowing = true
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
