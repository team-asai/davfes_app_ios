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

class NewsVC:UIViewController , UITableViewDataSource, UITableViewDelegate, HttpDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    let ud = UserDefaults.standard
    
    var selectedSectionId: Int!

    var barHeight: CGFloat!
    var displayWidth: CGFloat!
    var displayHeight: CGFloat!
    
    var news:NewsManager = NewsManager(newsName: "お知らせ")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "NewsVC"
        title = "お知らせ"
        
        news.delegate = self
        news.HttpGet()
        
        barHeight = UIApplication.shared.statusBarFrame.size.height
        displayWidth = self.view.frame.width
        // iPhone X 対応
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
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.reloadData()
    }
    
    // セクションヘッダータップ時
    func tapSectionHeader(_ sender: UIGestureRecognizer) {
        selectedSectionId = news.ids[(sender.view?.tag)!]
        performSegue(withIdentifier: "toNewsDetailViewController", sender: nil)
    }
    
    // セクションヘッダーの設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // セクション全体の角丸View
        let roundedCornerView:UIView = UIView()
        roundedCornerView.layer.cornerRadius = calc(5.0)
        roundedCornerView.layer.masksToBounds = true
        roundedCornerView.layer.borderWidth = calc(0.5)
        roundedCornerView.layer.borderColor =  UIColor.black.cgColor
        roundedCornerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        let myView: UIView = UIView()
        
        // ImageView用の角丸View
        let imageRoundedCornerView:UIView = UIView(frame: CGRect(x: 0.03*displayWidth, y: 0.1*(displayHeight/100*12), width: 0.8*(displayHeight/100*12), height: 0.8*(displayHeight/100*12)))
        imageRoundedCornerView.layer.cornerRadius = calc(5)
        imageRoundedCornerView.layer.masksToBounds = true
        imageRoundedCornerView.layer.borderWidth = calc(0.5)
        imageRoundedCornerView.layer.borderColor =  UIColor.black.cgColor
        myView.addSubview(imageRoundedCornerView)
        
        // 画像をダウンロードしてImageViewに配置
        let numImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0.8*(displayHeight/100*12), height: 0.8*(displayHeight/100*12)))
        
        let iconUrl = ud.string(forKey: "serverName")! + news.iconUrls[(news.titles.count - 1) - section]
        
        Alamofire.request(iconUrl, method: .get).responseImage { response in
            guard let image = response.result.value else {
                // Handle error
                return
            }
            // Do stuff with your image
            numImageView.image = image
        }
        imageRoundedCornerView.addSubview(numImageView)
        
        // タイトルラベル
        let title = UILabel(frame: CGRect(x: (80/375*displayWidth), y: 0.05*(displayHeight/100*12), width: (295/375*displayWidth), height: 0.6*(displayHeight/100*12)))
        title.text = news.titles[(news.titles.count - 1) - section]
        title.font = UIFont.systemFont(ofSize: calc(15.0))
        title.numberOfLines = 2
        myView.addSubview(title)
        
        // 日付ラベル
        let day = UILabel(frame: CGRect(x: 0.65*displayWidth, y: 0.65*(displayHeight/100*12), width: 0.35*displayWidth, height: 0.3*(displayHeight/100*12)))
        day.text = news.times[(news.titles.count - 1) - section]
        day.textColor = UIColor.black
        day.font = UIFont.systemFont(ofSize: calc(13.0))
        myView.addSubview(day)
        
        // セクションタップジェスチャーの登録
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PlanVC.tapSectionHeader(_:)))
        roundedCornerView.addGestureRecognizer(gesture)
        roundedCornerView.tag = section
        
        roundedCornerView.addSubview(myView)
        return roundedCornerView
    }
    
    // 端末サイズに合わせて，大きさを変更してくれる(Widthを基準に大きさ調整)
    func calc(_ val: Double) -> CGFloat{
        var ans: CGFloat!
        ans = (CGFloat(val)/375.0) * displayWidth
        return ans
    }
    
    // セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // セクションの数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.news.titles.count
    }
    
    // セクションの高さ設定
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (displayHeight/100*12)
    }
    
    // セル作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toNewsDetailViewController") {
            let subVC: NewsDetailVC = (segue.destination as? NewsDetailVC)!
            subVC.selectedSectionId = self.selectedSectionId
            subVC.news = self.news
        }
    }
    
    // Httpダウンロード完了時に呼ばれる
    func didDownloadData() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
