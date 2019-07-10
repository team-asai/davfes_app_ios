//
//  BeaconPlaces.swift
//  Davinci
//
//  Created by TakamatsuMasaya on 2017/07/24.
//  Copyright © 2017年 高松将也. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

/**
 ビーコンの設置場所情報を取って来て、キャッシュに格納
 その他jsonの操作に関するいくつかのメソッドを持つシングルトンクラス
 ビーコンの情報をサーバにPOSTする機能を追加
 */
class BeaconPlaces{
    
    let ud = UserDefaults.standard
    
    // URLの指定
    lazy var getUrl = "\(self.ud.string(forKey: "serverName")!)api/resources/beaconPlace"
    lazy var postUrl: String = "\(self.ud.string(forKey: "serverName")!)api/post/beacon"
    
    var json: JSON!
    

    class var sharedInstance: BeaconPlaces{
        struct Static{
            static let instance : BeaconPlaces = BeaconPlaces()
        }
        return Static.instance
    }
    
    init (){
        HttpGet()
    }
    
    func HttpGet() {
        print("ビーコンプレイスID一覧取得開始")
        Alamofire.request(getUrl)
            .responseJSON { response in
                guard let object = response.result.value else {
                    print("ビーコンプレイスID一覧を取得できませんでした")
                    return
                }
                print("ビーコンプレイスID一覧を取得しました")
                self.json = JSON(object)
        }
    }
    
    // major,minorの一致するビーコン情報（JSON）を返す
    func BeaconMatching(beacon: CLBeacon) -> JSON?{
        var beaconPlaceJson: JSON? = nil
        if json != nil {
            // 検知したビーコンに合わせて適切なJsonを返す
            json.forEach { (_, json) in
                if(json["major"].int == Int(truncating: beacon.major)){
                    if(json["minor"].int == Int(truncating: beacon.minor)){
                         print("ビーコン情報と取得値が一致しました")
                        beaconPlaceJson = json
                    }
                }
            }
            return beaconPlaceJson
            
        }else{
            // 何もしない
        }
        return nil
    }
    
    func noticeVisiting(major: String, minor: String) {
        print("ビーコン情報送信開始")
        let deviceToken: String! = String(describing: ud.object(forKey: "deviceToken")!)
        let uuid: String = "00000000-6DC8-1001-B000-001C4D88ED46"
        let major: String = major
        let minor: String = minor

        // 送信するパラメータの設定
        let params: [String: String] = [
            "os": "ios" as String,
            "deviceToken": deviceToken as String,
            "uuid": uuid as String,
            "major": major as String,
            "minor": minor as String
        ]
        
        let headers: HTTPHeaders = [
            "Contenttype": "application/json"
        ]
        
        Alamofire.request(postUrl, method: .post, parameters: params, encoding: URLEncoding(destination: .queryString), headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print("ビーコン情報を送信しました")
                print(result)
            } else {
                print("ビーコン情報の送信に失敗しました")
                print(response)
            }
        }

    }
}
