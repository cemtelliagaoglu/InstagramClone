//
//  SelectImageVC.swift
//  InstagramClone
//
//  Created by admin on 6.01.2023.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    //MARK: - Properties
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    var header: SelectPhotoHeader?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // register cell classes
        
        collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        collectionView.backgroundColor = .white
        // configure nav buttons
        configureNavigationButtons()
        
        // fetchPhotos
        fetchPhotos()
        
    }
    
    //MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return images.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        
        self.header = header
        
        if let selectedImage = self.selectedImage{
            // When photoImageView.image was set directly selectedImage became blurry
            // To overcome the blur issue, the code should be written as following
            // index selected image
            if let index = self.images.firstIndex(of: selectedImage){
                // asset associated with selected image
                let asset = self.assets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                // request image
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: nil) { image, info in
                    
                    header.photoImageView.image = image
                }
            }
            
            
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
        cell.photoImageView.image = self.images[indexPath.row]
        
        return cell
    }
    //MARK: - Handlers
    
    @objc func handleCancel(){
        self.dismiss(animated: true,completion: nil)
    }
    
    @objc func handleNext(){
        let uploadPostVC = UploadPostVC()
        uploadPostVC.selectedImage = self.header?.photoImageView.image
        navigationController?.pushViewController(uploadPostVC, animated: true)
    }
    
    func configureNavigationButtons(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
    }
    
    func getAssetFetchOptions() -> PHFetchOptions{
        
        let options = PHFetchOptions()
        // fetch limit
        options.fetchLimit = 30
        
        // sort photos by date
        let sortDesriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDesriptor]
        
        
        return options
        
    }
    func fetchPhotos(){
        
        let allPhotos = PHAsset.fetchAssets(with: .image,options: getAssetFetchOptions())
        
        // fetch images background thread
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { asset, count, stop in
            
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                // request image representation for specified asset
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, info in
                    
                    if let image = image{
                        // append image to data source
                        self.images.append(image)
                        
                        // append asset to data source
                        self.assets.append(asset)
                        
                        // set selected image with first image
                        if self.selectedImage == nil{
                            self.selectedImage = image
                        }
                        // reload collection view with images once count has completed
                        if count == allPhotos.count - 1{
                            // reload collection view on main thread
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
}
