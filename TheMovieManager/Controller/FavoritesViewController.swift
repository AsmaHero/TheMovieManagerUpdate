//
//  FavoritesViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       TMDBClient.getFavorites() { movies, error in
            MovieModel.favorites = movies
            // main thread here we remove it since we used getdatatask inside getWatchList , we did not need it any more.
            self.tableView.reloadData()
        }
        
    }
    // this function below to enable the favorites shown in real time after updating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = MovieModel.favorites[selectedIndex]
        }
    }
    
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieModel.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
        let movie = MovieModel.favorites[indexPath.row]
        
        cell.textLabel?.text = movie.title
        // to set the image that is already downloaded in movie details that is related to table view and make the image fast loaded without delays
        cell.imageView?.image = UIImage(named: "PosterPlaceHolder")
        if let posterpath = movie.posterPath{
            TMDBClient.downloadpoasterImage(path: posterpath){ data,  Error
                in
                guard let data = data else{
                    return
                }
                let image = UIImage(data: data)
                // once we have image downloaded we just have image in imageview
                cell.imageView?.image = image
                // we nned to update the contents to show the images immediately without waiting for the use to interact with the screen because the layout is custom, this feature prevent that from happend
                cell.setNeedsLayout()

            }
    }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
