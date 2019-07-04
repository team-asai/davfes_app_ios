//
//  FavoListManager.swift
//  Davinci
//
//  Created by TakamatsuMasaya on 2017/07/26.
//  Copyright © 2017年 高松将也. All rights reserved.
//

import Foundation
import Alamofire


// 本年度の企画出展の件数は66件
// アプリ内では7番の企画がクイズ大会であるため，7は基本的に常にfalse
class FavoListManager{
    
    let ud = UserDefaults.standard
    
    // ポストするURLの指定
    lazy var postUrl = "\(self.ud.string(forKey: "serverName")!)api/post/favorite"
    
    class var sharedInstance: FavoListManager{
        struct Static{
            static let instance : FavoListManager = FavoListManager()
        }
        return Static.instance
    }
    
    init (){
    }
    
    func getFavoList() -> [String]{
        print("お気に入り情報取得")
        var favoList:[String] = []
        for i in 1...100{
            if(self.ud.object(forKey: String(i)) as! Bool){
                favoList.append(String(i))
            }
        }
        return favoList
    }
    
    func sendFavoIdList(){
        
        print("お気に入り情報送信")
        
        let favoIdList:[String] = getFavoList()
        
        let deviceToken: String! = String(describing: ud.object(forKey: "deviceToken")!)

        
        let headers: HTTPHeaders = [
            "Contenttype": "application/json"
        ]
        // データベースに格納するときの形式
        var favoIdStr = ""
        favoIdList.forEach() {favoId in
            // おしゃれな三項演算子さん
            favoIdStr += favoId != favoIdList[0] ? ":"+favoId : favoId
        }
        
        // 送信するパラメータの設定
        let params: [String: String] = [
            "os": "ios" as String,
            "deviceToken": deviceToken as String,
            "favoIdList": favoIdStr as String
        ]
        
        Alamofire.request(postUrl, method: .post, parameters: params, encoding: URLEncoding(destination: .queryString), headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print("お気に入り情報を送信しました")
                print(result)
            } else {
                print("お気に入り情報の送信に失敗しました")
            }
        }
    }
}
