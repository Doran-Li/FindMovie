//
//  Movie.swift
//  FindMovie
//
//  Created by DIANHUA on 2021-04-09.
//

import Foundation
import CoreData

struct Movies: Codable {
    var resultCount: Int?
    var results: [Movie]?
}

struct Movie: Codable, Comparable {
    var kind: String?
    var artistName: String?
    var trackName: String?
    var trackViewUrl: URL?
    var previewUrl: URL?
    var artworkUrl30: URL?
    var artworkUrl60: URL?
    var artworkUrl100: URL?
    var trackPrice: Float?
    var trackRentalPrice: Float?
    var releaseDate: String?
    var country: String?
    var primaryGenreName: String?
    var shortDescription: String?
    var longDescription: String?
    
    static func < (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.trackName! < rhs.trackName!
    }
}
