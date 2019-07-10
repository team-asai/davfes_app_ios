//
//  rootVC.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/03.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

// トップページでは画面回転を禁止する
class RootVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "RootVC"
        
        let ud = UserDefaults.standard
        
        // サーバーの名前をudで保存しておく、ここ1箇所変更すればOK
        let serverName = "http://mini.puc.pu-toyama.ac.jp/davfes_app/"
        ud.set(serverName, forKey: "serverName")
        
        // ビーコンのモニタリング開始
        BeaconManager.sharedInstance.startMyMonitoring()
        
        // 起動時にビーコンのプレイス情報をサーバから引っ張ってきとく
        BeaconPlaces.sharedInstance.HttpGet()
        
        // 起動時にInfoページの画像を引っ張ってきとく
//         InfoManager.sharedInstance.HttpGet()
        
        // 起動時にマップページのテキストを引っ張ってきとく
//         MapManager.sharedInstance.HttpGet()
        
        // インストールして最初に起動した時だけ呼ばれる
        if(ud.object(forKey: "2018") == nil){
            print("初回起動")
            for i in 1...100{
                ud.set(false , forKey: String(i))
            }
            // 初回起動時にudの"first"キーをtrueにする
            ud.set(true, forKey: "2018")
            ud.synchronize()
        }
//        VersionChecker.sharedInstance.HttpGet(rootvc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

