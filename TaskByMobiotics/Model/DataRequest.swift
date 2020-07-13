//
//  VideoRequest.swift
//  TaskByMobiotics
//
//  Created by Kap's on 10/07/20.
//

import Foundation

enum DataError : Error {
    case noDataAvailable
    case canNotProcessData
}

struct DataRequest {
    
    let resourceURL : URL
    
    init() {
        let resourceString = "https://interview-e18de.firebaseio.com/media.json?print=pretty"
        guard let resourceURL = URL(string: resourceString) else { print("Could not hit url"); fatalError() }
        self.resourceURL = resourceURL
    }
    
    func getVideos(completion : @escaping ( Result<[DataModel], DataError> ) -> Void ) {
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL, completionHandler: { (data, _, _) in
            
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dataResponse = try decoder.decode([DataModel].self, from: jsonData)
                print(type(of: dataResponse))
                let dataDetails = dataResponse
                print(type(of: dataDetails))
                completion(.success(dataDetails))
            } catch {
                completion(.failure(.canNotProcessData))
            }
        })
        dataTask.resume()
    }
}
