//
//  FeedVC.swift
//  InstagramClone
//
//  Created by admin on 24.12.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    //MARK: - Properties
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.backgroundColor = .white
        
        configureNavController()
        
        fetchPosts()
    }

    //MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50 // actionButtons at bottom
        height += 60
        return CGSize(width: width, height: height)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.post = posts[indexPath.row]
        cell.delegate = self
        // Configure the cell
    
        return cell
    }

    //MARK: - Handlers
    func configureNavController(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.title = "Feed"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
    }
    
    @objc func handleShowMessages(){
        print("handle show messages")
    }
    @objc func handleLogout(){
        // declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // add alert action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            do{
                try Auth.auth().signOut()
                let navController = UINavigationController(rootViewController: LoginVC())
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            } catch{
                print("Failed to sign out: \(error)")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController,animated: true)
    }
    //MARK: - API
    
    func fetchPosts(){
        POSTS_REF.observe(.childAdded) { snapshot in
            let postId = snapshot.key
            
            guard let dictionary = snapshot.value as? Dictionary<String,AnyObject> else{ return }
            guard let ownerUid = dictionary["ownerUid"] as? String else{ return }
            
            Database.fetchUser(with: ownerUid) { user in
                
                let post = Post(postId: postId,user: user, dictionary: dictionary)
                
                Database.fetchPost(with: postId) { post in
                    
                    self.posts.append(post)
                    
                    self.posts.sort(by: {$0.creationDate > $1.creationDate})
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }

}
//MARK: - FeedCellDelegate Protocol
extension FeedVC: FeedCellDelegate{
    
    func handleUsernameTapped(for cell: FeedCell) {
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        guard let user = cell.post?.user else{ return }
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        print("handle options tapped")
    }
    
    func handleLikeTapped(for cell: FeedCell) {
        print("handle like tapped")
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        print("handle comment tapped")
    }
    
    
}
