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
    var viewSinglePost = false
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        configureNavController()
        
        if !viewSinglePost{
            fetchPosts()
        }
        
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
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if viewSinglePost{
            return 1
        }else{
            return posts.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        if viewSinglePost{
            if let post = self.post{
                cell.post = post
            }
        }else{
            cell.post = posts[indexPath.row]
        }
        
        return cell
    }

    //MARK: - Handlers
    @objc func handleRefresh(){
        posts.removeAll(keepingCapacity: false)
        fetchPosts()
        collectionView.reloadData()
    }
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
        
        guard let currentUid = Auth.auth().currentUser?.uid else{ return }
        
        USER_FEED_REF.child(currentUid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            
            Database.fetchUser(with: currentUid) { user in
                
                Database.fetchPost(with: postId) { post in
                    
                    self.posts.append(post)
                    
                    self.posts.sort(by: {$0.creationDate > $1.creationDate})
                    // end refreshing
                    self.collectionView.refreshControl?.endRefreshing()
                    
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
