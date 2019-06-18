//
//  MarkWatchlist.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct AddWatchlist: Codable {
    let media_type: String
    let media_id: Int
    let watchlist: Bool
    
    enum CodingKeys: String, CodingKey {
        case media_type = "media_type"
        case media_id = "media_id"
        case watchlist = "watchlist"
}
}
