//
//  TMDBResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
struct TMDBResponse: Codable {
    let status_code: Int
    let status_message: String
    
    enum CodingKeys: String, CodingKey {
        case status_code = "status_code"
        case status_message = "status_message"
}

}
// to provide error messages that is more readable using localized error
extension TMDBResponse: LocalizedError {
    var errorDescription: String? {
        return status_message
    }
}
