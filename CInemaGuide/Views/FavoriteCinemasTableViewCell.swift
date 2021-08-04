//
//  FavoriteCinemasTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/12/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class FavoriteCinemasTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cinemaNameLebel: UILabel!
    @IBOutlet weak var cinemaMoviesCollectionView: UICollectionView!
    
    var moviesArray = [MovieModel]()
    var selectedMovieID = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cinemaMoviesCollectionView.delegate = self
        cinemaMoviesCollectionView.dataSource = self
        cinemaMoviesCollectionView.register(UINib(nibName: "FavoriteCinemasMovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteCinemasMovieCell")
        cinemaMoviesCollectionView.scrollsToTop = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func initCellWith(movies: [MovieModel], cinemaName: String) {
        moviesArray = movies
        cinemaNameLebel.text = cinemaName
        cinemaMoviesCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if moviesArray.count != 0 {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favoriteCinemaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCinemasMovieCell", for: indexPath) as! FavoriteCinemasMovieCollectionViewCell
        let cinemaMoviesData = moviesArray[indexPath.row]
        let poster = cinemaMoviesData.poster
        let posterURLs = poster?["url"] as! [String : Any]
        let posterURL = posterURLs["large"] as? String ?? ""
        favoriteCinemaCell.initCellWith(posterURLString: posterURL)
        return favoriteCinemaCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMovieID = moviesArray[indexPath.row].id
        NotificationCenter.default.post(name: Notification.Name("openMovie"), object: selectedMovieID)
    }
}
