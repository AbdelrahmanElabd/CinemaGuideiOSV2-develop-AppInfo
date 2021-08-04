//
//  MoviesTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/11/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: - Properties
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    var moviesArray: [MovieModel]!
    var selectedMovieID: Int!
    
    //MARK: - View Lifecycle Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        moviesCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCollectionViewCell")
        
        moviesCollectionView.scrollsToTop = false
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            if #available(iOS 9.0, *) {
                moviesCollectionView.semanticContentAttribute = .forceRightToLeft
            } else {
                // Fallback on earlier versions
            }
        } else {
            if #available(iOS 9.0, *) {
                moviesCollectionView.semanticContentAttribute = .forceLeftToRight
            } else {
                // Fallback on earlier versions
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func initCellWith(movies: [MovieModel]) {
        moviesArray = movies
        moviesCollectionView.reloadData()
    }
    
    //MARK: - Collection View Functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let array = moviesArray {
            if array.count != 0 {
                return 1
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.moviesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let movieData = moviesArray[indexPath.row] 
        movieCollectionViewCell.initCellWith(movieData: movieData)
        return movieCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 132, height: 185)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieData = moviesArray[indexPath.row]
        selectedMovieID = movieData.id
        NotificationCenter.default.post(name: Notification.Name("openMovie"), object: selectedMovieID)
    }
}
