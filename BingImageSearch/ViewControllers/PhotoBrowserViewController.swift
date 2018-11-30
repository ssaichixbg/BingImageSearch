//
//  PhotoBrowserViewController.swift
//  BingImageSearch
//
//  Created by Yang Zhang on 11/29/18.
//  Copyright © 2018 Yang Zhang. All rights reserved.
//

import UIKit

class PhotoBrowserCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotoBrowserCollectionViewCell"
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    func prepare(image: BingImage) {
        imageView.yy_setImage(with: URL(string: image.contentUrl), options: .allowInvalidSSLCertificates)
        titleLabel.text = image.name
        subtitleLabel.text = image.contentUrl
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.yy_cancelCurrentImageRequest()
    }
}

class PhotoBrowserViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    var currentIndex = 0
    let searchService = BingImageSearchService.shared
    let moadMoreThreshold = 4
    var dataSource:[BingImage] = []
    var firstShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = collectionView.bounds.size
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = size
        layout.minimumLineSpacing = 0
        if firstShow {
            firstShow = false
            if currentIndex < dataSource.count {
                collectionView.setContentOffset(CGPoint(x: size.width * CGFloat(currentIndex), y: 0), animated: false)
            }
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func reload() {
        dataSource = searchService.imageResult
        collectionView.reloadData()
    }
}

extension PhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserCollectionViewCell.identifier, for: indexPath) as! PhotoBrowserCollectionViewCell
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
}
