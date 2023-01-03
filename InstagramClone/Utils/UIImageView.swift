//
//  UIImageView.swift
//  InstagramClone
//
//  Created by admin on 28.12.2022.
//

import UIKit

var imageCache = [String: UIImage]()
extension UIImageView{
    func loadImage(with urlString: String){
        // check if image exists in imageCache
        if let cachedImage = imageCache[urlString]{
            self.image = cachedImage
            return
        }
        // if image does not exist in cache
        // url for image location
        guard let url =  URL(string: urlString) else { return }
        
        // fetch contents of URL
        URLSession.shared.dataTask(with: url) { data, response, err in
            // handle error
            if let error = err{
                print("Failed to load image with error: \(error)")
            }
            //imageData
            guard let imageData = data else{ return }
            
            // set image using imageData
            let photoImage = UIImage(data: imageData)
            
            // set key and value for imageCache
            imageCache[url.absoluteString] = photoImage
            
            // set image
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
