//
//  SessionResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//responses

import Foundation
struct SessionResponse: Codable {
    let success: Bool
    let session_id: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case session_id = "session_id"
    }
}




