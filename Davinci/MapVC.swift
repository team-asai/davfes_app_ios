//
//  MapVC.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/19.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class MapVC: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var mapImageView: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!

    
    var navigationBarHeight: CGFloat = 0;
    var barHeight: CGFloat = 0
    var displayWidth: CGFloat = 0
    var displayHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "MapVC"
        
//        イカしたnilチェック
        if let json = MapManager.sharedInstance.json {
            print("nilチェック")
            label1.text = json["label1"].stringValue
            label2.text = json["label2"].stringValue
            label3.text = json["label3"].stringValue
            label4.text = json["label4"].stringValue
        }

        navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
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
        
        label1.adjustsFontSizeToFitWidth = true
        label2.adjustsFontSizeToFitWidth = true
        label3.adjustsFontSizeToFitWidth = true
        label4.adjustsFontSizeToFitWidth = true
        label4.numberOfLines = 2
        
        
        
        // スクロールビューの設定
        self.myScrollView.delegate = self
        self.myScrollView.minimumZoomScale = 1
        self.myScrollView.maximumZoomScale = 2
        self.myScrollView.isScrollEnabled = true
        self.myScrollView.showsHorizontalScrollIndicator = true
        self.myScrollView.showsVerticalScrollIndicator = true
        
//        let newScale:CGFloat = self.myScrollView.zoomScale * 1.1
//        let zoomRect:CGRect = self.zoomRectForScale(newScale, center: CGPoint(x: mapImageView.frame.width/2, y: mapImageView.frame.height/2))
//        self.myScrollView.zoom(to: zoomRect, animated: true)
        
        let newScale:CGFloat = self.myScrollView.zoomScale * 1.5
        let zoomRect:CGRect = self.zoomRectForScale(newScale, center: CGPoint(x: -100, y: -100))
        self.myScrollView.zoom(to: zoomRect, animated: true)
        
//        x:45, y:70（iPhone6sで微調整した）ピクセル分スクロールした状態にする
        self.myScrollView.contentOffset = CGPoint(x: calc(45), y: calc(70))
        
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self
            , action:#selector(StageIventVC.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.mapImageView.isUserInteractionEnabled = true
        self.mapImageView.addGestureRecognizer(doubleTapGesture)
        
        mapImageView.image = UIImage(named: "map")
    }
    
    // 端末サイズに合わせて，大きさを変更してくれる(Widthを基準に大きさ調整)
    func calc(_ val: Double) -> CGFloat{
        var ans: CGFloat!
        ans = (CGFloat(val)/375.0) * displayWidth
        return ans
    }
    
    // ピンチイン・ピンチアウト
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mapImageView
    }
    
    // ダブルタップ
    func doubleTap(_ gesture: UITapGestureRecognizer) -> Void {
        
        print(self.myScrollView.zoomScale)
        if ( self.myScrollView.zoomScale < self.myScrollView.maximumZoomScale ) {
            
            let newScale:CGFloat = self.myScrollView.zoomScale * 1.5
            let zoomRect:CGRect = self.zoomRectForScale(newScale, center: gesture.location(in: gesture.view))
            self.myScrollView.zoom(to: zoomRect, animated: true)
            
        } else {
            self.myScrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    // 領域
    func zoomRectForScale(_ scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.myScrollView.frame.size.height / scale
        zoomRect.size.width = self.myScrollView.frame.size.width / scale
        
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        
        return zoomRect
    }
    
    func updateText(beacon: CLBeacon){
        // CLBeaconのProximityはINTで返っててくる
        var proximity = ""
        switch (beacon.proximity) {
        case CLProximity.unknown :
            proximity = "Unknown"
            break
        case CLProximity.far:
            proximity = "Far"
            break
        case CLProximity.near:
            proximity = "Near"
            break
        case CLProximity.immediate:
            proximity = "Immediate"
            break
        }
        
        label3.text = "現在地を取得しました!!"
        label4.text = "Major: \(beacon.major) Minor: \(beacon.minor) \n Proximity:\(proximity) RSSI:\(beacon.rssi)"
    }
    
    func updateLocation(json: JSON){
        print("updateLocation")
        
        // ラベルの更新
        label3.text = "現在地を取得しました!!"
        label4.textColor = UIColor.brown
        label4.font = UIFont.systemFont(ofSize: calc(30.0))
        label4.text = "\(json["room"])"
        
        // イメージの更新
        if let img = UIImage(named: "\(json["map_name"])") {
            mapImageView.image = img
        }else{
            mapImageView.image = UIImage(named: "map")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
