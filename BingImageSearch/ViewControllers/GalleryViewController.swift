//
//  GalleryViewController.swift
//  BingImageSearch
//
//  Created by Yang Zhang on 11/29/18.
//  Copyright © 2018 Yang Zhang. All rights reserved.
//

import UIKit
import YYWebImage

class GalleryCollectionViewCell: UICollectionViewCell {
    static let identifier = "GalleryCollectionViewCell"
    @IBOutlet var imageView: UIImageView!
    
    func prepare(image: BingImage) {
        imageView.yy_setImage(with: URL(string: image.thumbnailUrl), options: .allowInvalidSSLCertificates)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.yy_cancelCurrentImageRequest()
    }
}

class GalleryViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    let searchService = BingImageSearchService.shared
    let moadMoreThreshold = 4
    var dataSource:[BingImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let itemWidth = 0.5 * collectionView.bounds.width - 20;
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let photoBrowserVC = segue.destination as? PhotoBrowserViewController,
            let indexPath = sender as? IndexPath {
            photoBrowserVC.currentIndex = indexPath.item
        }
    }
    
    func reload() {
        dataSource = searchService.imageResult
        collectionView.reloadData()
    }
    
    func search(_ nextText: String) {
        searchService.search(nextText) { [weak self](suc, kw) in
            guard kw == nextText else { return }
            if !suc {
                
            }
            else {
                self?.reload()
            }
        }
    }
}

extension GalleryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let nextText = (searchBar.text as NSString? ?? "").replacingCharacters(in: range, with: text)
        search(nextText)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }
}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as! GalleryCollectionViewCell
        let offset = indexPath.item
        if offset < dataSource.count {
            cell.prepare(image: dataSource[offset])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // load more data
        let keyword = searchService.keyword
        if indexPath.item > dataSource.count - moadMoreThreshold {
            searchService.loadMore { [weak self](suc, kw) in
                guard suc && keyword == kw else { return }
                self?.reload()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: indexPath)
    }
}
