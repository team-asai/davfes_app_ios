//
//  PlanVC.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/05.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ChildrenVC:UIViewController , UITableViewDataSource, UITableViewDelegate, HttpDelegate, BackActionDelegate{
    
    @IBOutlet var tableView: UITableView!
    fileprivate var openedSections = Set<Int>()
    
    var selectedSectionId:Int!
    
    let ud = UserDefaults.standard
    
    var barHeight: CGFloat!
    var displayWidth: CGFloat!
    var displayHeight: CGFloat!
    
    var ratio:CGFloat = 0.15
    
    var plans:PlanManager = PlanManager(planName: "こども製作教室")
    var delegater: Delegater = Delegater(delegaterName: "delegater")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        
        restorationIdentifier = "ChildrenVC"
        title = "こども製作教室"
        
        barHeight = UIApplication.shared.statusBarFrame.size.height
        displayWidth = self.view.frame.width
        // iPhoneX 対応
        // また画像比率がおかしな端末がきたらここを変えるべし
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                print("iPhone X")
                displayHeight = self.view.frame.height - 150
            default:
                displayHeight = self.view.frame.height
            }
        } else {
            // iPadの場合
            displayHeight = self.view.frame.height
        }

        delegater.delegate = self
        
        plans.delegate = self
        plans.HttpGet()
        
        tableView.reloadData()
    }
    
    // 端末サイズに合わせて，大きさを変更してくれる(Widthを基準に大きさ調整)
    func calc(_ val: Double) -> CGFloat{
        var ans: CGFloat!
        ans = (CGFloat(val)/375.0) * displayWidth
        return ans
    }
    
    // 戻るボタンで戻った時に呼ばれる
    func didBackAction() {
        self.tableView.reloadData()
        print("backAction")
    }
    
    // セクションヘッダータップ時
    func tapSectionHeader(_ sender: UIGestureRecognizer) {
        if(Double(sender.location(in: sender.view).x) > Double(0.85*displayWidth) && Double(sender.location(in: sender.view).y) > Double(0.5*ratio*displayHeight)){
            print("お気に入りタップ")

            if(ud.object(forKey: String(plans.ids[(sender.view?.tag)!])) as! Bool == false){
                ud.set(true, forKey: String(plans.ids[(sender.view?.tag)!]))
                
                // お気にいり情報をサーバに送信
                FavoListManager.sharedInstance.sendFavoIdList()
            }else if(ud.object(forKey: String(plans.ids[(sender.view?.tag)!])) as! Bool == true){
                ud.set(false, forKey: String(plans.ids[(sender.view?.tag)!]))
                
                // お気にいり情報をサーバに送信
                FavoListManager.sharedInstance.sendFavoIdList()
            }
            self.tableView.reloadData()
        }else{
            print("Normal")
            selectedSectionId = sender.view?.tag
            print(selectedSectionId)
            performSegue(withIdentifier: "toChildrenDetailVerticalViewController", sender: nil)
        }
    }
    
    // セクションヘッダーの設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // 角丸View
        let roundedCornerView:UIView = UIView()
        roundedCornerView.layer.cornerRadius = calc(10)
        roundedCornerView.layer.masksToBounds = true
        roundedCornerView.layer.borderWidth = calc(0.5)
        roundedCornerView.layer.borderColor =  UIColor.black.cgColor
        roundedCornerView.backgroundColor = UIColor(red: 241/255, green: 242/255, blue: 243/255, alpha: 1.0)
        
        let myView: UIView = UIView()
        myView.backgroundColor = UIColor.green
        
        // セクション番号イメージ
        let numImageView = UIImageView(frame: CGRect(x: 10/375*displayWidth, y: (10/667*displayHeight), width: (50/375*displayWidth), height: (50/667*displayHeight)))
        if(plans.ids[section] < 10){
            numImageView.image = UIImage(named: "0\(plans.ids[section])")
        }else{
            numImageView.image = UIImage(named: String(plans.ids[section]))
        }
        myView.addSubview(numImageView)
        
        // いいねボタンイメージ
        let favoImageView = UIImageView(frame: CGRect(x: (335/375*displayWidth), y: (60/667*displayHeight), width: (35/375*displayWidth), height: (35/667*displayHeight)))
        if(ud.object(forKey: String(plans.ids[section])) as! Bool == true){
            favoImageView.image = UIImage(named: "heart")
        }else if(ud.object(forKey: String(plans.ids[section])) as! Bool == false){
            favoImageView.image = UIImage(named: "heart_off")
        }
        myView.addSubview(favoImageView)
        
        // センションタイトルラベル
        let sectionTitle = UILabel(frame: CGRect(x: (70/375*displayWidth), y: (10/667*displayHeight), width: (285/375*displayWidth), height: (50/667*displayHeight)))
        sectionTitle.text = plans.sections[section]
        sectionTitle.font = UIFont.systemFont(ofSize: calc(20.0))
        sectionTitle.numberOfLines = 2
        sectionTitle.adjustsFontSizeToFitWidth = true
        myView.addSubview(sectionTitle)
        
        // ターゲットラベル
        let target = UILabel(frame: CGRect(x: (130/375*displayWidth), y: (60/667*displayHeight), width: (205/375*displayWidth), height: (35/667*displayHeight)))
        target.text = "対象：\(plans.targets[section])"
        target.textColor = UIColor.black
        target.font = UIFont.systemFont(ofSize: calc(15.0))
        myView.addSubview(target)
        
        // セクションタップジェスチャーの登録
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PlanVC.tapSectionHeader(_:)))
        roundedCornerView.addGestureRecognizer(gesture)
        roundedCornerView.tag = section
        
        roundedCornerView.addSubview(myView)
        return roundedCornerView
    }
    
    // セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.openedSections.contains(section) {
            return 1
        } else {
            return 0
        }
    }
    
    // セクションの数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        //print(self.items.count)
        return self.plans.sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Int(ratio*displayHeight))
    }
    
    // セルの作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0.3*displayHeight
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toChildrenDetailVerticalViewController") {
            let subVC: ChildrenDetailVerticalVC = (segue.destination as? ChildrenDetailVerticalVC)!
            subVC.selectedSectionId = self.selectedSectionId
            subVC.plans = self.plans
            subVC.delegater = self.delegater
            print("Verticle")
        }
    }
    
    // データダウンロード完了時に呼ばれる
    func didDownloadData(){
        print("finish")
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
