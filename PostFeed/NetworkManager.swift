//
//  NetworkManager.swift
//  PostFeed
//
//  Created by Владислав Шушпанов on 24.08.2021.
//

import Foundation

class NetworkManager {
    
    func request(lastId: Int = 0, lastSortingValue: Int = 0, completion: @escaping (PostData?) -> Void) {
        
        let parameters = self.prepareParaments(lastId: lastId, lastSortingValue: lastSortingValue)
        let url = self.url(params: parameters)
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        let task = createDataTask(from: request, completion: completion)
        task.resume()
//
//        guard let url = URL(string: "https://api.tjournal.ru/v2.0/timeline?allSite=true&sorting=date&subsitesIds=1%2C%202&hashtag=%D0%B8%D0%B3%D1%80%D1%8B") else { return }
//
//
//        let session = URLSession.shared
//        session.dataTask(with: url) { (data, response, error) in
//            guard let data = data else { return }
//
//            let postData = self.decodeJSON(type: PostData.self, data: data)
//
//            DispatchQueue.main.async {
//                completion(postData)
//            }
//
//        }.resume()
        
    }
    
    
    private func prepareParaments(lastId: Int = 0, lastSortingValue: Int = 0) -> [String: String] {
        var parameters = [String: String]()
        parameters["allSite"] = "true"
        parameters["sorting"] = "date"
        parameters["subsitesIds"] = "1%2C%202"
        parameters["hashtag"] = "%D0%B8%D0%B3%D1%80%D1%8B"
        parameters["lastId"] = String(lastId)
        parameters["lastSortingValue"] = String(lastSortingValue)
        return parameters
    }
    
    private func url(params: [String: String]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.tjournal.ru"
        components.path = "/v2.0/timeline"
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1)}
        return components.url!
    }
    
    private func createDataTask(from request: URLRequest, completion: @escaping (PostData?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            let postData = self.decodeJSON(type: PostData.self, data: data)
            DispatchQueue.main.async {
                completion(postData)
            }
        }
    }
    
    
    func decodeJSON<T: Decodable>(type: T.Type, data: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = data else { return nil }
        
        do {
            let json = try decoder.decode(type.self, from: data)
            return json
        } catch let error {
            print(error)
            return nil
        }
    }
    
}
