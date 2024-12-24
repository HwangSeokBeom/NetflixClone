//
//  Video.swift
//  NetflixClone
//
//  Created by 내일배움캠프 on 12/23/24.
//

import Foundation

struct VideoResponse: Decodable {
    let results: [Video]
}

struct Video: Decodable {
    let key: String?
    let site: String?
    let type: String?
}
