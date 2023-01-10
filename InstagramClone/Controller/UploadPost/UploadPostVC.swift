//
//  UploadPostVC.swift
//  InstagramClone
//
//  Created by admin on 24.12.2022.
//

import UIKit
import FirebaseAuth

class UploadPostVC: UIViewController, UITextViewDelegate {

    //MARK: - Properties
    var selectedImage: UIImage?
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .systemGroupedBackground
        tv.font = .systemFont(ofSize: 12)
        return tv
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255 , blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure view components
        configureViewComponents()
        // load image
        loadImage()
        
        captionTextView.delegate = self
        
    }
    //MARK: - UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else{
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255 , blue: 244/255, alpha: 1)
            return
        }
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
    
    //MARK: - Handler
    
    @objc func handleSharePost(){
        
        // parameters
        guard let caption = captionTextView.text,
              let postImage = photoImageView.image,
              let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // image upload data
        guard let uploadData = postImage.jpegData(compressionQuality: 0.5) else { return }
                // creation date
                let creationDate = Int(NSDate().timeIntervalSince1970)
                // update storage
                let filename = NSUUID().uuidString
                let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
                storageRef.putData(uploadData) { metadata, err in
                    if let error = err{
                        print("Failed to upload image to storage with error: \(error)")
                        return
                    }
                    // image url
                    storageRef.downloadURL { url, error in
                        guard let imageURL = url?.absoluteString else { return }
                        let values = ["caption": caption,
                                      "creationDate": creationDate,
                                      "likes": 0,
                                      "imageURL": imageURL,
                                      "ownerUid": currentUid] as [String: Any]
                        // post id
                        let postId = POSTS_REF.childByAutoId()
                        guard let postKey = postId.key else{ return }
                        // upload information to database
                        postId.updateChildValues(values) { error, ref in
                            
                            // update user-posts structure
                            let userPostsRef = USER_POSTS_REF.child(currentUid)
                            userPostsRef.updateChildValues([postKey: 1])
                            
                            // return to home feed
                            self.dismiss(animated: true) {
                                self.tabBarController?.selectedIndex = 0
                            }
                            
                        }
                        
                    }
                    
                }
    }
    
    
    func configureViewComponents(){
        view.backgroundColor = .white
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
    }

    func loadImage(){
        
        guard let selectedImage = self.selectedImage else{ return }
        
        photoImageView.image = selectedImage
        
    }
   
}
