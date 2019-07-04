//
//  MapManager.swift
//  Davinci
//
//  Created by TakamatsuMasaya on 2017/08/03.
//  Copyright © 2017年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class MapManager{
    
    let getUrl = "http://ik1-303-11641.vs.sakura.ne.jp/2017/Map/labelText.json"
    var json: JSON? = nil

    
    class var sharedInstance: MapManager{
        struct Static{
            static let instance : MapManager = MapManager()
        }
        return Static.instance
    }
    
    init (){
        
    }
    
    func HttpGet() {
        Alamofire.request(getUrl)
            .responseJSON { response in
                guard let object = response.result.value else {
                    print("ErrorHTTP")
                    return
                }
                self.json = JSON(object)
//                if self.json != nil{
//                    print(self.json!["label1"])
//                }
                
        }
    }
}
