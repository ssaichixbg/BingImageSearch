//
//  Image.swift
//  BingImageSearch
//
//  Created by Yang Zhang on 11/29/18.
//  Copyright © 2018 Yang Zhang. All rights reserved.
//

import UIKit

struct BingImage: Codable {
    let name: String
    let hostPageDisplayUrl: String
    let contentUrl: String
    let thumbnailUrl: String
    
    init(dictionary: Dictionary<String, Any>) {
        name = dictionary["name"] as? String ?? ""
        hostPageDisplayUrl = dictionary["hostPageDisplayUrl"] as? String ?? ""
        contentUrl = dictionary["contentUrl"] as? String ?? ""
        thumbnailUrl = dictionary["thumbnailUrl"] as? String ?? ""
    }
}
