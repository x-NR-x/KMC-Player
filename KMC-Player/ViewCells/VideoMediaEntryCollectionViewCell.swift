//
//  VideoMediaEntryCollectionViewCell.swift
//  KMC-Player
//
//  Created by Nilit Danan on 3/20/18.
//  Copyright © 2018 Nilit Danan. All rights reserved.
//

import UIKit
import KalturaClient

class VideoMediaEntryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var videoMediaEntry: MediaEntry? = nil {
        willSet {
            // set default image
            
            guard var imageURLString = newValue?.thumbnailUrl else {
                return
            }
            imageURLString.append("/width/\(thumbnailImageView.frame.size.width)/height/\(thumbnailImageView.frame.size.height)")
            guard let imageURL = URL(string: imageURLString) else {
                return
            }
            thumbnailImageView.downloadedFrom(url: imageURL)
        }
    }
    
    override func prepareForReuse() {
        self.thumbnailImageView.image = nil // Set to a default image
    }
}
