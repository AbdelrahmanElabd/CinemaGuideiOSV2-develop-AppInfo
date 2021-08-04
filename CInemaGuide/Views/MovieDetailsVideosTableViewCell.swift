//
//  MovieDetailsVideosTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/4/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class MovieDetailsVideosTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var trailersCollectionView: UICollectionView!
    
    var trailers = [[String : Any]]()
    var selectedTrailerURL : String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        trailersCollectionView.register(UINib(nibName: "MovieDetailsVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieDetailsVideoCollectionCell")
        trailersCollectionView.delegate = self
        trailersCollectionView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWith(trailersArray: [[String: Any]]) {
        trailers = trailersArray
        trailersCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if trailers.count != 0 {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if trailers.count != 0 {
            return trailers.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let trailerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailsVideoCollectionCell", for: indexPath) as! MovieDetailsVideoCollectionViewCell
        let aTrailer = trailers[indexPath.row]
        let thumb = aTrailer["previewImage"] as! [String: Any]
        let thumbURLs = thumb["url"] as! [String: Any]
        trailerCell.initCellWith(videoThumbURLString: thumbURLs["large"] as? String ?? "", videoURLString: aTrailer["videoUrl"] as? String ?? "")
        return trailerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 260, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let aTrailer = trailers[indexPath.row]
        selectedTrailerURL = aTrailer["videoUrl"] as! String
        NotificationCenter.default.post(name: Notification.Name("OpenTrailerVideo"), object: selectedTrailerURL)
    }
}
