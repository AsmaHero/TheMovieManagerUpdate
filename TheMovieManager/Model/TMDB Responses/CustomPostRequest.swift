//
//  CustomPostRequest.swift
//  TheMovieManager
//
//  Created by Asmahero on ٧ رمضان، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Udacity. All rights reserved.
//

import Foundation
import CoreFoundation

// create a Codable struct called "POST" with the correct properties
struct Post: Codable {
    let userId: Int
    let title: String
    let body: String
}
func postRequest(){
// create an instance of the Post struct with your own values
let post = Post(userId: 1, title: "udacity", body: "udacious")

// create a URLRequest by passing in the URL
var request = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
// set the HTTP method to POST
request.httpMethod = "POST"
// set the HTTP body to the encoded "Post" struct
request.httpBody = try! JSONEncoder().encode(post)
// set the appropriate HTTP header fields
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
// HACK: this line allows the workspace or an Xcode playground to execute the request, but is not needed in a real app
let runLoop = CFRunLoopGetCurrent()
// task for making the request
let task = URLSession.shared.dataTask(with: request) {data, response, error in
    print(String(data: data!, encoding: .utf8))
    // also not necessary in a real app
    CFRunLoopStop(runLoop)
}
task.resume()
// not necessary
CFRunLoopRun()
}
