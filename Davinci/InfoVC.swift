//
//  InfoVC.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/16.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit

class InfoVC: UIViewController{
    
    @IBOutlet weak var top_button: UIButton!
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBAction func toWebButton(_ sender: UIButton) {
        
        let alertController:UIAlertController = UIAlertController(title: "Safariで開く", message: "ダ・ヴィンチ祭ホームページ", preferredStyle: .alert)
            
        // 選択肢
        // 異なる方法でactionを設定してみた
        let actionOK = UIAlertAction(title: "開く", style: .default){
            action in
            let url = URL(string: "http://www.davinci-fest.net")
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.openURL(url!)
            }
        }
        
        let actionCancel = UIAlertAction(title: "キャンセル", style: .cancel){
            (action) -> Void in
        }
        
        // actionを追加
        alertController.addAction(actionOK)
        alertController.addAction(actionCancel)
        
        // UIAlertの起動
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closeModalDialog(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "InfoVC"
        
////        アプリ起動時にちゃんと画像をダウンロードして来て来れてたら、画像を差し替える
//        if InfoManager.sharedInstance.image1 != nil {
//            top_button.setImage(InfoManager.sharedInstance.image1, for: UIControlState.normal)
//        }
//        
//        if(InfoManager.sharedInstance.image2 != nil){
//            myImageView.image = InfoManager.sharedInstance.image2
//        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
