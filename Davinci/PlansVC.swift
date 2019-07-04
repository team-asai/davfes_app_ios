//
//  PlansVC.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/05.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit

class PlansVC: UIViewController , UITableViewDataSource, UITableViewDelegate, BackActionDelegate{
    
    @IBOutlet var table: UITableView!
    
    let imgArray: NSArray = ["特別コラボ企画","おもしろ科学縁日","大学探検隊","こども製作教室","その他いろいろ"]
    
    var selectedPlan: String!
    
    var barHeight: CGFloat!
    var displayWidth: CGFloat!
    var displayHeight: CGFloat!
    
    var ratio:CGFloat = 0.18
    
    var delegater: Delegater = Delegater(delegaterName: "delegater")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "PlansVC"
        
        delegater.delegate = self
        
        barHeight = UIApplication.shared.statusBarFrame.size.height
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Int(ratio*displayHeight))
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        //let cell = table.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        let cell = UITableViewCell()
        // 角丸のビュー
        print(cell.frame.width, cell.frame.height)
        let roundedCornerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: CGFloat(Int(ratio*displayHeight))))
        roundedCornerView.layer.cornerRadius = 10
        roundedCornerView.layer.masksToBounds = true
        roundedCornerView.layer.borderWidth = 0.5
        roundedCornerView.layer.borderColor =  UIColor.black.cgColor
        roundedCornerView.backgroundColor = UIColor.white
        
        
        //let imgName: String = imgArray[indexPath.row] as! String
        let imgName: String = "\(imgArray[indexPath.row])_矢印あり"
        let img = UIImage(named:imgName)
        
        // Tag番号 1 で UIImageView インスタンスの生成
        // let imageView = table.viewWithTag(1) as! UIImageView
        let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: CGFloat(Int(ratio*displayHeight))))
        imageView.image = img
        roundedCornerView.addSubview(imageView)
        
        
        cell.addSubview(roundedCornerView)

        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        selectedPlan = imgArray[indexPath.row] as! String
        // 製作教室が選択された場合
        if(selectedPlan != nil){
            if(selectedPlan == "こども製作教室"){
                performSegue(withIdentifier: "toChildrenController", sender: nil)
            }
            else{
                performSegue(withIdentifier: "toPlanController", sender: nil)
            }
        }
    }
    
    // 戻るボタンが押された時
    func didBackAction() {
        self.table.reloadData()
        print("backAction")
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toPlanController") {
            let subVC: PlanVC = (segue.destination as? PlanVC)!
            subVC.selectedPlan = selectedPlan
            subVC.delegater = self.delegater
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
