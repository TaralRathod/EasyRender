//
//  File.swift
//  
//
//  Created by Twinkle Rathod on 31/05/24.
//

import SwiftUI
import Combine
import Photos

class ImageCache: NSObject , NSDiscardableContent {

    public var image: UIImage!

    func beginContentAccess() -> Bool {
        return true
    }

    func endContentAccess() {

    }

    func discardContentIfPossible() {

    }

    func isContentDiscarded() -> Bool {
        return false
    }
}


final class CombineNetworkManager {
    
    // MARK: - Singleton
    static let shared = CombineNetworkManager()
    
    
    // MARK: - Value
    // MARK: Private
    private lazy var imageCache = NSCache<NSString, ImageCache>()
    
    private let queue = DispatchQueue(label: "ImageDataManagerQueue")
    

    private lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 90
        configuration.timeoutIntervalForRequest     = 90
        configuration.timeoutIntervalForResource    = 90
        return URLSession(configuration: configuration)
    }()
    
    
    // MARK: - Initializer
    private init() {}
    
    
    // MARK: - Function
    // MARK: Public
    func download(url: URL?) async throws -> Image {
        guard let url = url else { throw URLError(.badURL) }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            return Image(uiImage: cachedImage.image)
        }

        let data = (try await downloadSession.data(from: url)).0
        
        guard let image = UIImage(data: data) else { throw URLError(.badServerResponse) }
        let cachedImage = ImageCache()
        cachedImage.image = image
        queue.async { self.imageCache.setObject(cachedImage, forKey: url.absoluteString as NSString) }
    
        return Image(uiImage: image)
    }
}
