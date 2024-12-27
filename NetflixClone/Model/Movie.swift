//
//  Movie.swift
//  NetflixClone
//
//  Created by 내일배움캠프 on 12/23/24.
//

import Foundation

struct MovieResponse: Decodable {
    typealias Element = Movie
    let results: [Movie]
}

struct Movie: Decodable {
    let id: Int?
    let title: String?
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
    }
}
