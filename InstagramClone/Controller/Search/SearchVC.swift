//
//  SearchVC.swift
//  InstagramClone
//
//  Created by admin on 24.12.2022.
//

import UIKit
import FirebaseDatabase

class SearchVC: UITableViewController {
    //MARK: - Properties
    
    private let reuseIdentifier = "SearchUserCell"
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // register cell classes
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // separator insets to locate profileImage to the center of cell
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        configureNavController()
        // fetch users
        fetchUsers()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! SearchUserCell
        cell.user = users[indexPath.row]
        return cell
    }
  
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        // create instance of UserProfileVC
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from SearchVC to UserProfileVC
        userProfileVC.user = user
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    //MARK: - Handlers
    func configureNavController(){
        self.navigationItem.title = "Explore"
    }
    
    //MARK: - API
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            
            let uid = snapshot.key
            
            Database.fetchUser(with: uid) { user in
                
                self.users.append(user)
                
                self.tableView.reloadData()
            }
        }
    }
}
