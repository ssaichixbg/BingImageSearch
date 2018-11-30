//
//  BingImageSearchService.swift
//  BingImageSearch
//
//  Created by Yang Zhang on 11/29/18.
//  Copyright © 2018 Yang Zhang. All rights reserved.
//

import UIKit
import Alamofire

class BingImageSearchService: NSObject {
    enum API: String {
        case searchV7 = "/bing/v7.0/images/search"
    }
    
    public static let shared = BingImageSearchService()
    
    let hostName = "https://api.cognitive.microsoft.com"
    let headers: HTTPHeaders = [
        "Ocp-Apim-Subscription-Key": BingImageApiKey,
    ]

    var imageResult: [BingImage] = []
    
    var dataRequest: DataRequest?
    var keyword = ""
    fileprivate var offset: Int = 0
    
    func search(_ kw: String?, onFinish: @escaping (Bool, String) -> ()) {
        guard let kw = kw, kw.count > 0 else {
            imageResult = []
            keyword = ""
            dataRequest = nil
            onFinish(true, "")
            return
        }
        
        dataRequest?.cancel()
        dataRequest = nil
        sendSearchRequest(keyword: kw, offset: 0, onFinish: onFinish)
    }
    
    func loadMore(onFinish: @escaping (Bool, String) -> ()) {
        guard dataRequest == nil else {
            return
        }
        
        sendSearchRequest(keyword: keyword, offset: offset, onFinish: onFinish)
    }
    
    fileprivate func sendSearchRequest(keyword kw: String, offset off: Int, onFinish: @escaping (Bool, String) -> ()) {
        keyword = kw
        let parameters: Parameters = [
            "q": kw
            ,
            "offset": off,
            "count": "10",
            "mkt": "en-us"
        ]
        dataRequest = Alamofire.request(hostName + API.searchV7.rawValue, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: { [weak self](response) in
            guard let self = self else { return }
            self.dataRequest = nil
            
            guard let json = response.result.value as? Dictionary<String, Any>,
                let value = json["value"] as? Array<Dictionary<String, Any>> else {
                onFinish(false, kw)
                return
            }

            let images = value.map({ BingImage(dictionary: $0) })
            if off == 0 {
                self.imageResult = images
            }
            else {
                self.imageResult.append(contentsOf: images)
            }
            self.offset = self.imageResult.count
            
            onFinish(true, kw)
            })
    }
}
