//
//  imageSevice.swift
//  PostFeed
//
//  Created by Владислав Шушпанов on 24.08.2021.
//

import UIKit

class ImageService {
    let MB = 1024 * 1024
    let session = URLSession.shared
    let cacheImage: URLCache
    
    init() {
        cacheImage = URLCache(memoryCapacity: 50 * MB, diskCapacity: 100 * MB, diskPath: "images")
    }

    func get(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        if let cachedResponse = cacheImage.cachedResponse(for: URLRequest(url: url)) {
            let image = UIImage(data: cachedResponse.data)
            completion(image)
           
            return
        }
          
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data , let response = response else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let image = UIImage(data: data)
            
            let cachedResponse = CachedURLResponse(response: response, data: data)
            self.cacheImage.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
