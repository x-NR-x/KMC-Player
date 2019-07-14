//
//  MediaCollectionViewController.swift
//  KMC-Player
//
//  Created by Nilit Danan on 3/14/18.
//  Copyright © 2018 Nilit Danan. All rights reserved.
//

import UIKit
import PlayKit
import KalturaClient

class MediaCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var selectedEntryImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var selectedVideoMediaEntry: MediaEntry? {
        willSet {
            guard var imageURLString = newValue?.thumbnailUrl else {
                return
            }
            imageURLString.append("/width/\(selectedEntryImageView.frame.size.width)/height/\(selectedEntryImageView.frame.size.height)")
            guard let imageURL = URL(string: imageURLString) else {
                return
            }
            selectedEntryImageView.downloadedFrom(url: imageURL)
            
            playButton.isHidden = !(newValue != nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playButton.isHidden = !(self.selectedVideoMediaEntry != nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateCellSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserManager.shared.isUserLoggedIn() {
            self.performSegue(withIdentifier: "DisplayLoginView", sender: self)
        } else {
            self.fetchMediaListData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "PlaySelectedEntrySegue"?:
            guard let destinationViewController = segue.destination as? MediaPlayerViewController else {
                return
            }
            destinationViewController.mediaEntry = self.selectedVideoMediaEntry
            return
        default:
            print("Unhandled Segue")
            return
        }
    }
    
    @IBAction func unwindToCollectionViewController(segue:UIStoryboardSegue) {
        
    }
    
    // MARK: - Private Methods
    
    func fetchMediaListData() {
        BaseEntryManager.shared.list { (error) in
            if error != nil {
                let alert = UIAlertController(title: "Media", message: error?.message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                self.show(alert, sender: nil)
            }
            else {
                self.mediaCollectionView.reloadData()
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.collectionView(self.mediaCollectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
                }
            }
        }
    }
    
    func updateCellSize() {
        let ratio: CGFloat = 16/9
        
        let cellInset: CGFloat = 1
        
        let width = self.mediaCollectionView.frame.size.width - 2 * cellInset
        var cellWidth: CGFloat = width
        var cellHeight: CGFloat
    
        if UIDevice.current.orientation.isPortrait {
            cellWidth = (width - 2 * cellInset) / 2
        }
        
        cellHeight = cellWidth / ratio
        
        let cellSize = CGSize(width: cellWidth, height: cellHeight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: cellInset, left: cellInset, bottom: cellInset, right: cellInset)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        self.mediaCollectionView.setCollectionViewLayout(layout, animated: true)
    }

    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let objects = BaseEntryManager.shared.videoMediaEntryListObjects else {
            return 0
        }
        
        return objects.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoMediaEntryCollectionViewCell", for: indexPath) as! VideoMediaEntryCollectionViewCell
        
        let row = indexPath.row
        
        guard let videoMediaEntryListObjects = BaseEntryManager.shared.videoMediaEntryListObjects else {
            return cell
        }
        
        let videoMediaEntry = videoMediaEntryListObjects[row] as? MediaEntry

        cell.videoMediaEntry = videoMediaEntry
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoMediaEntryCollectionViewCell else {
            return
        }
        self.selectedVideoMediaEntry = cell.videoMediaEntry
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.mediaCollectionView.collectionViewLayout.invalidateLayout()
        
        DispatchQueue.main.async {
            self.updateCellSize()
            self.mediaCollectionView.reloadData()
        }
    }
}
