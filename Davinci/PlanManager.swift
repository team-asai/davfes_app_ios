//
//  PlanManager.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/24.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class PlanManager{
    
    enum CustomError: Error{
        case unexpectedString
    }
    
    var planName: String!
    let ud = UserDefaults.standard
    
    lazy var urls:Dictionary! = [
        "全企画" : "\(self.ud.string(forKey: "serverName")!)api/resources/plan",
        "こども製作教室" : "\(self.ud.string(forKey: "serverName")!)api/resources/seisakuKyoshitsu",
        "特別コラボ企画" : "\(self.ud.string(forKey: "serverName")!)api/resources/tokubetsuKikaku",
        "大学探検隊" : "\(self.ud.string(forKey: "serverName")!)api/resources/daigakuTankentai",
        "おもしろ科学縁日" : "\(self.ud.string(forKey: "serverName")!)api/resources/kagakuEnnichi",
        "その他いろいろ" : "\(self.ud.string(forKey: "serverName")!)api/resources/sonota"
    ]
    
    var ids:[Int] = []
    var sections:[String] = []
    var targets:[String] = []
    var contents:[String] = []
    var times:[String] = []
    var timeReqs:[String] = []
    var spots:[String] = []
    var layoutStyles:[String] = []
    var imgUrls:[String] = []
    var places:[String] = []
    var floors:[String] = []
    var reserveInfos:[String] = []
    
    var delegate: HttpDelegate?
    
    init (planName: String){
        self.planName = planName
        
    }
    
    // 初期化時に指定された企画名の企画を取得
    func HttpGet() {
        print("企画情報取得開始 : \(planName)")
        
        //--------------------------ここからHTTP通信でJSON読み込み--------------------------
        
        Alamofire.request(urls[planName]!)
            .responseJSON { response in
                guard let object = response.result.value else {
                    print("企画情報をしゅとくできませんでした")
                    return
                }
                print("企画情報を取得しました")
                let json = JSON(object)
                
                let plans = json[self.planName]

                plans.forEach { (_, json) in
                    if json["id"].int != nil {
                        self.ids.append(json["id"].int!) }
                    if json["name"].string != nil {
                        self.sections.append(json["name"].string!) }
                    if json["target"].string != nil {
                        self.targets.append(json["target"].string!) }
                    if json["contents"].string != nil {
                        self.contents.append(json["contents"].string!) }
                    if json["time"].string != nil {
                        self.times.append(json["time"].string!) }
                    if json["timeReq"].string != nil {
                        self.timeReqs.append(json["timeReq"].string!) }
                    if json["spot"]["place"].string != nil && json["spot"]["floor"].string != nil && json["spot"]["room"].string != nil {
                        self.spots.append("\(json["spot"]["place"]) \(json["spot"]["floor"]) \(json["spot"]["room"])") }
                    if json["layoutStyle"].string != nil {
                        self.layoutStyles.append(json["layoutStyle"].string!) }
                    if json["imgUrl"].string != nil {
                        self.imgUrls.append(json["imgUrl"].string!) }
                    if json["spot"]["place"].string != nil {
                        self.places.append(json["spot"]["place"].string!) }
                    if json["spot"]["floor"].string != nil {
                        self.floors.append(json["spot"]["floor"].string!) }
                    if json["reserveInfo"].string != nil {
                        self.reserveInfos.append(json["reserveInfo"].string!) }
                }
                self.delegate?.didDownloadData()
        }
        //--------------------------ここまで--------------------------
        
    }
    
    // お気にいりされているものだけ取得
    func HttpGetWithOnlyFavoritePlans(){
        
        print("お気に入り企画情報取得開始 : \(planName)")
        
        //--------------------------ここからHTTP通信でJSON読み込み--------------------------
        Alamofire.request(urls[planName]!)
            .responseJSON { response in
                guard let object = response.result.value else {
                    print("お気に入り企画情報を取得できませんでした")
                    return
                }
                print("お気に入り企画情報を取得しました")
                let json = JSON(object)
                
                let plans = json[self.planName]

                plans.forEach { (_, json) in
                    // いいねボタンが押されている企画だけ抜粋している
                    if(self.ud.object(forKey: String(json["id"].int!)) as! Bool){
                        if json["id"].int != nil {
                            self.ids.append(json["id"].int!) }
                        if json["name"].string != nil {
                            self.sections.append(json["name"].string!) }
                        if json["target"].string != nil {
                            self.targets.append(json["target"].string!) }
                        if json["contents"].string != nil {
                            self.contents.append(json["contents"].string!) }
                        if json["time"].string != nil {
                            self.times.append(json["time"].string!) }
                        if json["timeReq"].string != nil {
                            self.timeReqs.append(json["timeReq"].string!) }
                        if json["spot"]["place"].string != nil && json["spot"]["floor"].string != nil && json["spot"]["room"].string != nil {
                            self.spots.append("\(json["spot"]["place"]) \(json["spot"]["floor"]) \(json["spot"]["room"])") }
                        if json["layoutStyle"].string != nil {
                            self.layoutStyles.append(json["layoutStyle"].string!) }
                        if json["imgUrl"].string != nil {
                            self.imgUrls.append(json["imgUrl"].string!) }
                        if json["spot"]["place"].string != nil {
                            self.places.append(json["spot"]["place"].string!) }
                        if json["spot"]["floor"].string != nil {
                            self.floors.append(json["spot"]["floor"].string!) }
                        if json["reserveInfo"].string != nil {
                            self.reserveInfos.append(json["reserveInfo"].string!) }
                    }
                }
                self.delegate?.didDownloadData()
        }
        //--------------------------ここまで--------------------------
    }
}
