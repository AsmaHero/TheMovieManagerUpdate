//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        
        //not every movie has a poster that is why we write below code
        // if it has a posterpathimage , the parameter we passed in struct client
        //Use [weak self] when loading image in detail view
        //This ensures the image view is not retained after the detail view (and therefore the image view) no longer exists. to safe memory 
        if let posterpath = movie.posterPath{
            TMDBClient.downloadpoasterImage(path: posterpath){ [weak self] (data, error)
                in
                guard let data = data else{
                    return
                }
                let image = UIImage(data: data)
                // once we have image downloaded we just have image in imageview
                self?.imageView.image = image
                
                
            }
            
        }
        
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
 TMDBClient.markWatchlist(media_id: movie.id, watchlist: !isWatchlist, completion: handleRequestMarkWitchlist(success:error:))
        
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
 TMDBClient.markFavorites(media_id: movie.id, favorite: !isFavorite, completion: handleRequestMarkFavorites(success:error:))
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    func handleRequestMarkWitchlist(success: Bool, error: Error?)  {
        
        if success {
            if isWatchlist{
                //here we filter the item, if it is exist we just delete it , the movie contains the movie id in the array
                // when we handle we just waiting for a response then completed the steps if not return with something
           MovieModel.watchlist = MovieModel.watchlist.filter()
            { $0 != movie.self}
                
            }
        else {
                // if it is not in watchlist , we just adding that mpvie item to watchlist
              MovieModel.watchlist.append(movie)
        }
            // to highligh or not highligh the button depend on status , such as in the like button
            toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
          
    }

}
    func handleRequestMarkFavorites(success: Bool, error: Error?)  {
        
        if success {
            if isFavorite{
                //here we filter the item, if it is exist we just delete it , the movie contains the movie id in the array
                // when we handle we just waiting for a response then completed the steps if not return with something
                MovieModel.favorites = MovieModel.favorites.filter()
                    { $0 != movie.self}
                
            }
            else {
                // if it is not in watchlist , we just adding that mpvie item to watchlist
                MovieModel.favorites.append(movie)
            }
            // to highligh or not highligh the button depend on status , such as in the like button
            toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
            
        }
        
    }
}
