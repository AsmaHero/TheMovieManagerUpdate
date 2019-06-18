//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    // this apikey I got when I create api account that related to me
   
    //static let apiKey =  "YOUR_TMDB_API_KEY"
   static let apiKey = "0cbc6af387030223eb55c0f78ce49f74"
   // static let apiKey = ""
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let imagebase = "https://image.tmdb.org/t/p/w500"
        //<<api_key>> parameter
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
   
        // to search of specific value , we have to use associate values because we need to query or filter which is the String for the function getSearch. this is done by pass let query inside case
        case getSearch(String)
        case getWatchlist
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        case logout
        case getFavorites
        case markWatchlist
        case markFavorites
        case posterImageURL(String)
  
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken:
                return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
            case .login:
            return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
            case .createSessionId:
                return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
            case.webAuth:
                return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
            case.logout:
                return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
            case.getFavorites: //account id is a parameter
                return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getSearch(let query):
            return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))"
                //.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                // this line above with the query to make our input query is allowed in url with the spaces
                // = for numbers and ?apikey = for string
                // link not accept spaces and & represent and
                //.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                // this line above with the query to make our input query is allowed in url with the spaces
                // = for numbers and ?apikey = for string
                // link not accept spaces and & represent and
                
            case .markWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .markFavorites:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                
            case .posterImageURL( let posterpath):
                return Endpoints.imagebase + posterpath
                
// themoviemanager , url handled by the movie manager , authinticate is the the path. If we want to handle multible incoming url , we can specify different path. this is the url we want to 
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
 @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error
            in
            guard let data = data else {
                 DispatchQueue.main.async {
                completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                
               let responseObject = try decoder.decode(ResponseType.self , from: data)
               
                 DispatchQueue.main.async {
                // pass the responseobject if the parsing is successful
                completion(responseObject, nil)
                }
            }
                
            catch{
                do{
                     let errorResponse = try decoder.decode(TMDBResponse.self , from: data)
                    DispatchQueue.main.async {
                        // pass the responseobject if the parsing is successful
                        completion(nil, errorResponse)
                    }
                }
                catch{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }

            }
        }
        task.resume()
        return task
    }
    //<RequestType: Encodable> pass a generic type whatever the type
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void)
    {
        var rquest = URLRequest(url: url)
        rquest.httpMethod = "POST"
        // call the struct with passing parameters
        rquest.httpBody = try! JSONEncoder().encode(body)
        // tell the server that the data is json format
        rquest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: rquest) { data, response, error
            in
            guard let data = data else {
                 DispatchQueue.main.async {
                completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self , from: data)
                
                // pass the responseobject if the parsing is successful
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }
            catch{
                do {
                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func sessionIdRequest(completion: @escaping (Bool , Error?) -> Void) {
        taskForPOSTRequest(url: Endpoints.createSessionId.url , responseType: SessionResponse.self , body: PostSession(requestToken: Auth.requestToken)) { response , error
            in
            if let response = response {
                Auth.sessionId = response.session_id
                completion(true, nil)
            }
            else{
                 completion(false,error)
            }
        }
    }
    class func loginRequest(username: String, password: String, completion: @escaping (Bool , Error?) -> Void) {
        taskForPOSTRequest(url: Endpoints.login.url , responseType: RequestTokenResponse.self , body: LoginRequest(username: username, password: password, requestToken: Auth.requestToken)) { response , error
            in
            if let response = response {
               Auth.requestToken = response.requestToken
                completion(true, nil)
            }
            else{
                completion(false,error)
            }
        }
    }
    class func getRequestToken(completion: @escaping (Bool , Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getRequestToken.url , responseType: RequestTokenResponse.self) { response , error
            in
            if let response = response {
                 Auth.requestToken = response.requestToken
                    completion(true, nil)
            }
            else {
                completion(false, error)
            }
    }
    }
   
    class func logoutRequest(completion: @escaping () -> Void) {
 
        var rquest = URLRequest(url: Endpoints.logout.url)
        rquest.httpMethod = "DELETE"
        // tell the server that the data is json format
        rquest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // call the struct with passing parameters
        let body = LogoutRequest(session_id: Auth.sessionId)
        rquest.httpBody = try! JSONEncoder() .encode(body)
        //url request
        let task = URLSession.shared.dataTask(with: rquest) { (data, response, error) in
            Auth.requestToken = ""
            Auth.sessionId = ""
                completion()
        }
        task.resume()
    }
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getWatchlist.url , responseType: MovieResults.self) { response , error in
            if let response = response {
                completion(response.results, nil)
            }
            else {
                completion([], error)
            }
        }
    }
    class func markWatchlist(media_id: Int, watchlist: Bool, completion: @escaping (Bool, Error?) -> Void) {
        
        taskForPOSTRequest(url: Endpoints.markWatchlist.url , responseType: TMDBResponse.self , body: AddWatchlist(media_type: "movie" , media_id: media_id, watchlist: watchlist)) { response , error
            in //status codes 1 ,12 ,13 returned successfully
            if let response = response {
                completion(response.status_code ==
                    1 || response.status_code ==
                    12 || response.status_code ==
                    13, nil)
            }
            else{
                completion(false,error)
            }
        }
    }
    class func markFavorites(media_id: Int, favorite: Bool, completion: @escaping (Bool, Error?) -> Void) {
        
        taskForPOSTRequest(url: Endpoints.markFavorites.url , responseType: TMDBResponse.self , body: MarkFavorite(media_type: "movie" , media_id: media_id, favorite: favorite)) { response , error
            in //status codes 1 ,12 ,13 returned successfully
            if let response = response {
                completion(response.status_code ==
                    1 || response.status_code ==
                    12 || response.status_code ==
                    13, nil)
            }
            else{
                completion(false,error)
            }
        }
    }
    class func getFavorites(completion: @escaping ([Movie], Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getFavorites.url , responseType: MovieResults.self) { response , error in
            if let response = response {
                completion(response.results, nil)
            }
            else {
                completion([], error)
            }
        }
    }
    class func getSearch(query: String, completion: @escaping ([Movie], Error?) -> Void) -> URLSessionDataTask  {
        
        let task = taskForGETRequest(url: Endpoints.getSearch(query).url , responseType: MovieResults.self) { response , error in
            if let response = response {
                completion(response.results, nil)
            }
            else {
                completion([], error)
            }
        }
        return task
    }
    class func downloadpoasterImage(path: String,  completion: @escaping (Data?, Error?) -> Void){
       let task =  URLSession.shared.dataTask(with: Endpoints.posterImageURL(path).url){ data, response, error
            in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
        
    }

}
