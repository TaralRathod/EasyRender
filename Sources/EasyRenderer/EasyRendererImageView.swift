//
//  EasyRenderer.swift
//  EasyRenderer
//
//  Created by Taral Rathod on 02/10/20.
//

import Foundation
import UIKit

public class EasyRendererImageView: UIImageView {

    // Cache object
    let imageCache = NSCache<NSString, UIImage>()

    // Data task object from Network manager class to stop perticular operation
    var task: URLSessionDataTask?

    public func getImageFor(url: String, placeholder: UIImage, completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        // Assigning Placeholder image
        self.image = placeholder

        // Checking in cache memory if not available than going for download
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            self.image = image
            completion(cachedImage, nil)
        } else {
            guard let url = URL(string: url) else {print("Invalid URL"); return}
            NetworkManager().downloadImage(url: url, delegate: self) { (data, error) in
                if error != nil {
                    completion(nil, error)
                } else if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                    completion(image, nil)
                } else {
                    completion(nil, nil)
                }
            }
        }
    }

    /// Canceling downloading of image
    public func cancelDownload() {
        task?.cancel()
    }
}
