//
//  Utility.swift
//  FindMovie
//
//  Created by DIANHUA on 2021-04-09.
//

import UIKit

struct Utility {
    static func fetchItems(matching query: [String: String], completion: @escaping ([Movie]?) -> Void) {
        let baseURL = Foundation.URL(string: "https://itunes.apple.com/search?")!
        guard let url = baseURL.withQueries(query) else {
            completion(nil)
            print("Unable to build URL with supplied queries.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let movies = try? jsonDecoder.decode(Movies.self, from: data) {
                completion(movies.results)
            } else {
                print("Either no data was returned, or data was not serialized.")
                completion(nil)
                return
            }
        }
        task.resume()
    }
    
    static let documentDictionery = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let URL = documentDictionery.appendingPathComponent("movies").appendingPathExtension("plist")
    
    static func encodeFile(movies: [Movie]) {
        let encoder = PropertyListEncoder()
        let encodeEmojis = try? encoder.encode(movies)
        try? encodeEmojis?.write(to: URL, options: .noFileProtection)
    }
    
    static func decodeFile() -> [Movie]? {
        guard let decodeEmojis = try? Data(contentsOf: URL) else {
            return nil
        }
        let decoder = PropertyListDecoder()
        return try? decoder.decode([Movie].self, from: decodeEmojis)
    }
}

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}

