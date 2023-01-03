//
//  FollowVC.swift
//  InstagramClone
//
//  Created by admin on 2.01.2023.
//

import UIKit
import Firebase

class FollowVC: UITableViewController{
    
    //MARK: - Properties
    private let reuseIdentifier = "FollowCell"
    var viewFollowers = false
    var viewFollowing = false
    var uid: String?
    var users = [User]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // configure nav controller
        if viewFollowers{
            navigationItem.title = "Followers"
        }else{
            navigationItem.title = "Following"
        }
        // clear separator lines
        tableView.separatorColor = .clear
        
        //fetch users
        fetchUsers()
    }
    //MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        cell.user = users[indexPath.row]
        cell.delegate = self
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - API
    func fetchUsers(){
        
        guard let uid = self.uid else { return }
        var ref: DatabaseReference!
        
        if viewFollowers{
            ref = USER_FOLLOWER_REF
        }else{
            ref = USER_FOLLOWING_REF
        }
        
        ref.child(uid).observeSingleEvent(of: .value) { snapshot in
            
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else{ return }
                
                allObjects.forEach { snapshot in
                    let userId = snapshot.key
                    
                    USER_REF.child(userId).observeSingleEvent(of: .value) { snapshot in
                        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                        
                        let user = User(uid: userId, dictionary: dictionary)
                        self.users.append(user)
                        
                        self.tableView.reloadData()
                }
            
            }
            
        }
        
    }
}
    //MARK: - FollowCellDelegate Protocol
extension FollowVC: FollowCellDelegate{
    
    func handleFollowTapped(for cell: FollowCell) {
        guard let user = cell.user else{ return }
        
        if user.isFollowed{
            user.unfollow()
            
            // configure follow button for non followed user
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            cell.followButton.layer.borderWidth = 0
            user.isFollowed = false
        }else{
            user.follow()
            user.isFollowed = true
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.backgroundColor = .white
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
        }
        
    }
    
    
}
