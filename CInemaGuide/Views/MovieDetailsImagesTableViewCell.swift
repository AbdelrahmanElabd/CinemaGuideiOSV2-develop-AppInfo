//
//  MovieDetailsImagesTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/4/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class MovieDetailsImagesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    var galleryArray = [[String: Any]]()
    var selectedImageURL : String!
    let imagesArray = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        galleryCollectionView.register(UINib(nibName: "MovieDetailsImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "galleryImageCollectionCell")
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWith(galleryData: [[String: Any]]) {
        galleryArray = galleryData
        galleryCollectionView.reloadData()
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if galleryArray.count != 0 {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if galleryArray.count != 0 {
            return galleryArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let galleryImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryImageCollectionCell", for: indexPath) as! MovieDetailsImagesCollectionViewCell
        let imageData = galleryArray[indexPath.row] 
        let imageURLs = imageData["url"] as! [String: Any]
        let imageLargeURLString = "\(AppInfoHelper.getMediaBaseURL())\(imageURLs["large"] ?? "")"
        let imageCaption = imageData["caption"] ?? "" 
        galleryImageCell.initCellWith(imageURL: imageLargeURLString, imageCaption: imageCaption as! String)
        imagesArray.add(imageLargeURLString)
        return galleryImageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width / 3 - 12, height: self.frame.size.width / 3 - 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        let imageData: [String: Any] = ["SelectedIndex": selectedIndex, "ImagesArray": imagesArray]
        NotificationCenter.default.post(name: Notification.Name("SelectImage"), object: imageData)
    }
}
