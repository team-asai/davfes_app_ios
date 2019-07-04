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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class PlanVC:UIViewController , UITableViewDataSource, UITableViewDelegate, HttpDelegate{
    
    @IBOutlet var tableView: UITableView!
    fileprivate var openedSections = Set<Int>()
    
    let ud = UserDefaults.standard

    var selectedPlan: String!
    
    var plans:PlanManager!
    var delegater: Delegater!
    
    var navigationBarHeight: CGFloat!
    var barHeight: CGFloat!
    var displayWidth: CGFloat!
    var displayHeight: CGFloat!
    
    var ratio:CGFloat = 0.15
    
    var sectionHeaderHeight:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "PlanVC"
        title = selectedPlan
        
//        navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
//        barHeight = UIApplication.shared.statusBarFrame.size.height
        navigationBarHeight = 0
        barHeight = 0
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height
        
        sectionHeaderHeight = CGFloat(Int(ratio*displayHeight))
        
        plans = PlanManager(planName: selectedPlan)
        plans.delegate = self
        
        plans.HttpGet()
        
        // 手動でテーブルビューのインセットを調整
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.contentInset = UIEdgeInsetsMake((navigationBarHeight + barHeight), 0, 0, 0)
        
        // 下部の余分なセパレータを消す
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // viewが廃棄される前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        if let viewControllers = self.navigationController?.viewControllers {
            var existsSelfInViewControllers = true
            for viewController in viewControllers {
                // viewWillDisappearが呼ばれる時に、
                // 戻る処理を行っていれば、NavigationControllerのviewControllersの中にselfは存在していない
                if viewController == self {
                    existsSelfInViewControllers = false
                    // selfが存在した時点で処理を終える
                    break
                }
            }
            if existsSelfInViewControllers {
                print("前の画面に戻る処理が行われました")
                self.delegater.BackAction()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    // 端末サイズに合わせて，大きさを変更してくれる(Widthを基準に大きさ調整)
    func calc(_ val: Double) -> CGFloat{
        var ans: CGFloat!
        ans = (CGFloat(val)/375.0) * displayWidth
        return ans
    }
    
    // セクションヘッダータップ時
    func tapSectionHeader(_ sender: UIGestureRecognizer) {
        if(Double(sender.location(in: sender.view).x) > Double(0.85*displayWidth) && Double(sender.location(in: sender.view).y) > Double(0.5*ratio*displayHeight)){
            print("お気に入り")

            if(ud.object(forKey: String(plans.ids[(sender.view?.tag)!])) as! Bool == false){
                ud.set(true, forKey: String(plans.ids[(sender.view?.tag)!]))
//                // お気にいり情報をサーバに送信
                FavoListManager.sharedInstance.sendFavoIdList()
//
            }else if(ud.object(forKey: String(plans.ids[(sender.view?.tag)!])) as! Bool == true){
                ud.set(false, forKey: String(plans.ids[(sender.view?.tag)!]))
//                // お気にいり情報をサーバに送信
                FavoListManager.sharedInstance.sendFavoIdList()
                
            }
           self.tableView.reloadData()
        }else{
            print("Normal")
            if let section = sender.view?.tag {
                if self.openedSections.contains(section) {
                    self.openedSections.remove(section)
                } else {
                    self.openedSections.insert(section)
                }
                self.tableView.reloadSections(IndexSet(integer: section), with: .fade)
            }
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
        
        // 下矢印イメージ
        let arrowImageView = UIImageView(frame: CGRect(x: (5/375*displayWidth), y: (25/667*displayHeight), width: (20/375*displayWidth), height: (20/667*displayHeight)))
        if(openedSections.contains(section)){
            arrowImageView.image = UIImage(named: "up")
        }else{
            arrowImageView.image = UIImage(named: "down")
        }
        
        myView.addSubview(arrowImageView)
        
        // セクション番号イメージ
        let numImageView = UIImageView(frame: CGRect(x: 30/375*displayWidth, y: (10/667*displayHeight), width: (50/375*displayWidth), height: (50/667*displayHeight)))
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
        let sectionTitle = UILabel(frame: CGRect(x: (90/375*displayWidth), y: (10/667*displayHeight), width: (285/375*displayWidth), height: (50/667*displayHeight)))
        sectionTitle.text = plans.sections[section]
        sectionTitle.font = UIFont.systemFont(ofSize: calc(20.0))
        sectionTitle.adjustsFontSizeToFitWidth = true
        sectionTitle.numberOfLines = 2
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
        return sectionHeaderHeight
    }
    
    // セルの作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        // 内容
        let contentsView = UIImageView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: 0.8*(0.3*displayHeight)))
        cell.addSubview(contentsView)
        
        // ＜内容＞ラベル
        let content = UILabel(frame: CGRect(x: (30/375*displayWidth), y: 0.05*contentsView.frame.height, width: displayWidth, height: 0.1*contentsView.frame.height))
        content.text = "＜内容＞"
        content.textColor = UIColor.black
        content.font = UIFont.systemFont(ofSize: calc(20.0))
        contentsView.addSubview(content)
        
        // コンテンツラベル
        let contentLabel = UILabel(frame: CGRect(x: (30/375*displayWidth), y: 0.15*contentsView.frame.height, width: (305/375*displayWidth), height: 0.85*contentsView.frame.height))
        contentLabel.text = plans.contents[indexPath.section]
        contentLabel.textColor = UIColor.black
        contentLabel.font = UIFont.systemFont(ofSize: calc(16.0))
        contentLabel.minimumScaleFactor = (calc(16.0) - 3) / (calc(16.0) + 3)
        contentLabel.adjustsFontSizeToFitWidth = true
        contentLabel.numberOfLines = 6
        contentsView.addSubview(contentLabel)
        
        // 出展場所
        let placeView = UIImageView(frame: CGRect(x: 0, y: 0.8*(0.3*displayHeight), width: displayWidth, height: 0.2*(0.3*displayHeight)))
        cell.addSubview(placeView)
        
        // ＜出展場所＞ラベル
        let place = UILabel(frame: CGRect(x: (30/375*displayWidth), y: 0, width: displayWidth, height: 0.1*(0.3*displayHeight)))
        place.text = "＜出展場所＞"
        place.textColor = UIColor.black
        place.font = UIFont.systemFont(ofSize: calc(16.0))
        placeView.addSubview(place)
        
        // プレイスラベル
        let placeLabel = UILabel(frame: CGRect(x: (45/375*displayWidth), y: 0.5*placeView.frame.height, width: (305/375*displayWidth), height: 0.1*(0.3*displayHeight)))
        placeLabel.text = plans.spots[indexPath.section]
        print(plans.places[indexPath.section])
        placeLabel.textColor = UIColor.black
        placeLabel.font = UIFont.systemFont(ofSize: calc(13.0))
        placeLabel.numberOfLines = 1
        placeView.addSubview(placeLabel)
        
        // タップ時に背景をグレーアウトせずホワイトのままにする
        let bView = UIView()
        bView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = bView

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0.3*displayHeight
    }
    
    // スクロール時，セクションタイトルを上に残さないようにするため
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.y <= (self.sectionHeaderHeight) && scrollView.contentOffset.y >= 0){
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
            
            print(scrollView.contentOffset.y)
        }else if(scrollView.contentOffset.y >= (self.sectionHeaderHeight)){
            scrollView.contentInset = UIEdgeInsetsMake(-self.sectionHeaderHeight, 0, 0, 0)        }else{
            self.tableView.contentInset = UIEdgeInsetsMake((navigationBarHeight + barHeight), 0, 0, 0)
        }
    }
    
    // データダウンロード完了時に呼ばれる
    func didDownloadData() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
