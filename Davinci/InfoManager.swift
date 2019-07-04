//
//  InfoManager.swift
//  Davinci
//
//  Created by TakamatsuMasaya on 2017/08/03.
//  Copyright © 2017年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class InfoManager{
    
    let getUrl1 = "http://ik1-303-11641.vs.sakura.ne.jp/2017/Info/web_button.png"
    let getUrl2 = "http://ik1-303-11641.vs.sakura.ne.jp/2017/Info/info_no_button.png"
    var image1: UIImage? = nil
    var image2: UIImage? = nil
    
    
    
    class var sharedInstance: InfoManager{
        struct Static{
            static let instance : InfoManager = InfoManager()
        }
        return Static.instance
    }
    
    init (){
        
    }
    
    func HttpGet() {
//        // 画像
//        Alamofire.request(getUrl1, method: .get).responseImage { response in
//            guard let img = response.result.value else {
//                // Handle error
//                return
//            }
//            // Do stuff with your image
//            self.image1 = img
//        }
//
//        // 画像
//        Alamofire.request(getUrl2, method: .get).responseImage { response in
//            guard let img = response.result.value else {
//                // Handle error
//                return
//            }
//            // Do stuff with your image
//            self.image2 = img
//        }
        
    }
}
