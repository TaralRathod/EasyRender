//
//  NetworkManager.swift
//  EasyRenderer
//
//  Created by Taral Rathod on 02/10/20.
//

import Foundation

class NetworkManager {
    // Method to download image
    func downloadImage(url: URL, delegate: EasyRendererImageView, completion: @escaping (_ imageData: Data?, _ error: Error? ) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0)
        request.httpMethod = "GET"
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error == nil {
                completion(data, nil)
            } else {
                completion(nil, error)
            }
        })
        // Assigning task object to imageView class for stopping particular task
        delegate.task = task
        task.resume()
    }
}
