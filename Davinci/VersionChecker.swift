////
////  VersionChecker.swift
////  Davinci
////
////  Created by TakamatsuMasaya on 2017/07/26.
////  Copyright © 2017年 高松将也. All rights reserved.
////
//
//import Foundation
//import UIKit
//import Alamofire
//import SwiftyJSON
//
//class VersionChecker{
//    
//    let url: String = "http://ik1-303-11641.vs.sakura.ne.jp/version"
//    var json:JSON!
//    
//    let version: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
//    let build: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
//    
//    class var sharedInstance: VersionChecker{
//        struct Static{
//            static let instance : VersionChecker = VersionChecker()
//        }
//        return Static.instance
//    }
//    
//    init (){
//        print(self.version!)
//        print(self.build!)
//    }
//    
//    func HttpGet(rootvc: UIViewController) {
//        Alamofire.request(url)
//            .responseJSON { response in
//                guard let object = response.result.value else {
//                    print("ErrorHTTP")
//                    return
//                }
//                self.json = JSON(object)
//                print(self.json["iOS"])
//                if self.version != nil {
//                    if (self.version != self.json["iOS"].stringValue){
//                        print("バージョンが違うためのアップデートのアラートを出します。")
//                        self.showAlert(rootvc: rootvc)
//                    }
//                }
//        }
//    }
//    
//    func showAlert(rootvc: UIViewController){
//        let alertController:UIAlertController = UIAlertController(title: "アップデートのお知らせ", message: "最新バージョンのアプリが公開されています。AppStoreで最新のアプリにアップデートしましょう。", preferredStyle: .alert)
//        
//        // 選択肢
//        // 異なる方法でactionを設定してみた
//        let actionOK = UIAlertAction(title: "AppStoreを開く", style: .default){
//            action in
//            let url = URL(string: "https://itunes.apple.com/us/app/%E3%83%80-%E3%83%B4%E3%82%A3%E3%83%B3%E3%83%81app2017/id1136129316?l=ja&ls=1&mt=8")
//            if UIApplication.shared.canOpenURL(url!){
//                UIApplication.shared.openURL(url!)
//            }
//        }
//        
//        let actionCancel = UIAlertAction(title: "キャンセル", style: .cancel){
//            (action) -> Void in
//        }
//        
//        // actionを追加
//        alertController.addAction(actionOK)
//        alertController.addAction(actionCancel)
//        
//        // UIAlertの起動
//        rootvc.present(alertController, animated: true, completion: nil)
//    }
//}
