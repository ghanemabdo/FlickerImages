//
//  ViewController.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/19/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import UIKit

class FlickrImagesGridViewController: UICollectionViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout, ImageIndexDelegate {
    
    @IBOutlet var searchingActivityIndicator: UIActivityIndicatorView? = nil
    
    let cellsPerRow = 3
    let margins = UIEdgeInsets(top: 30.0, left: 15.0, bottom: 30.0, right: 15.0)
    let cellReuseIden = "flickrImageCell"
    let searchController = UISearchController(searchResultsController: nil)
    var lastSearchKeywork: SearchKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // build and add the search bar
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -- UICollectionViewDataSource methods --
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImagesIndex.sharedInstance.TotalPhotos
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIden, for: indexPath) as! FlickrImageCell
        
        cell.resetCell()
        
        let index = getImageAtIndex(indexPath: indexPath)
        if let flickrImage = ImagesIndex.sharedInstance.getImageAtIndex(index: index, delegate: cell) {
            cell.setImage(flickrImage: flickrImage)
        }
        
        return cell
    }
    
    func getImageAtIndex(indexPath: IndexPath) -> Int {
        return indexPath.row
    }
    
    // MARK: -- UICollectionViewLayoutFlow methods --
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = Int(margins.left) * (cellsPerRow + 1)
        let availableWidth = Int(view.frame.width) - paddingSpace
        let widthPerItem = availableWidth / cellsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return margins
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return margins.left
    }
    
    // MARK: -- SearchBar delegates methods --
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = self.lastSearchKeywork
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let searchString = searchController.searchBar.text {
            self.lastSearchKeywork = searchString
            self.searchingActivityIndicator?.isHidden = false
            self.searchingActivityIndicator?.startAnimating()
            ImagesIndex.sharedInstance.searchForKey(searchKey: searchString, delegate: self)
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: -- JSONDownloadDelegate methods --
    func imageIndexDownloaded() {
        DispatchQueue.main.async {
            self.searchingActivityIndicator?.isHidden = true
            self.searchingActivityIndicator?.stopAnimating()
            self.collectionView?.reloadData()
        }
    }
}

