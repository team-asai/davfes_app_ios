//
//  News.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/25.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation

import UIKit
import Alamofire
import SwiftyJSON

class NewsManager{
    
    var newsName: String!
    
    let ud = UserDefaults.standard
    
    // URLの指定
    lazy var newsUrl = "\(self.ud.string(forKey: "serverName")!)api/resources/news"
    
    var ids:[Int] = []
    var titles:[String] = []
    var times:[String] = []
    var iconUrls:[String] = []
    var pictureUrls:[String] = []
    var contents:[String] = []
    
    var delegate: HttpDelegate?
    
    init (newsName: String){
        self.newsName = newsName
    }
    
    // お知らせ情報の取得
    func HttpGet() {
        print("ニュース情報取得開始")
        //--------------------------ここからHTTP通信でJSON読み込み--------------------------
        Alamofire.request(newsUrl)
            .responseJSON { response in
                guard let object = response.result.value else {
                    print("ニュース情報を取得できませんでした")
                    return
                }
                print("ニュース情報を取得しました")
                let json = JSON(object)
                let news = json[self.newsName]
                
                news.forEach { (_, json) in
                    self.ids.append(json["id"].int!)
                    self.titles.append(json["title"].string!)
                    self.times.append(json["time"].string!)
                    self.iconUrls.append(json["icon"].string!)
                    self.pictureUrls.append(json["picture"].string!)
                    self.contents.append(json["content"].string!)
                }
                self.delegate?.didDownloadData()
        }
    }
}
