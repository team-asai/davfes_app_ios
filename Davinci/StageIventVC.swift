//
//  StageIventVC.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/13.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit

class StageIventVC: UIViewController, UIScrollViewDelegate{
    
    
//    @IBOutlet weak var recieveView: UIView!
//    @IBOutlet weak var quizMornigView: UIView!
//    @IBOutlet weak var quizAfternoonView: UIView!
//    @IBOutlet weak var closingView: UIView!

    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var noBarView: UIView!
    
    var navigationBarHeight: CGFloat = 0;
    var barHeight: CGFloat = 0
    var displayWidth: CGFloat = 0
    var displayHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "StageIventVC"
        
//        navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        navigationBarHeight = 0
//        barHeight = UIApplication.shared.statusBarFrame.size.height
        barHeight = 0
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
        

        // スクロールビューの設定
        self.myScrollView.delegate = self
        self.myScrollView.minimumZoomScale = 1
        self.myScrollView.maximumZoomScale = 2
        self.myScrollView.isScrollEnabled = true
        self.myScrollView.showsHorizontalScrollIndicator = true
        self.myScrollView.showsVerticalScrollIndicator = true
        self.myScrollView.contentInset = UIEdgeInsets(top: -(navigationBarHeight + barHeight), left: 0, bottom: (navigationBarHeight + barHeight), right: 0)
//        if #available(iOS 11.0, *) {
//            self.myScrollView.contentInsetAdjustmentBehavior = .never
//        } else {
//            // Fallback on earlier versions
//        }
//
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self
            , action:#selector(StageIventVC.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.noBarView.isUserInteractionEnabled = true
        self.noBarView.addGestureRecognizer(doubleTapGesture)
//        recieveView.layer.cornerRadius = 5
//        recieveView.backgroundColor = UIColor(red: 165/255, green: 251/255, blue: 132/255, alpha: 35/100)
//        
//        quizMornigView.layer.cornerRadius = 5
//        quizMornigView.backgroundColor = UIColor(red: 165/255, green: 251/255, blue: 132/255, alpha: 50/100)
//        
//        quizAfternoonView.layer.cornerRadius = 5
//        quizAfternoonView.backgroundColor = UIColor(red: 255/255, green: 193/255, blue: 255/255, alpha: 50/100)
//        
//        closingView.layer.cornerRadius = 5
//        closingView.backgroundColor = UIColor(red: 252/255, green: 224/255, blue: 152/255, alpha: 50/100)
        
        
//        roundedCornerView.layer.cornerRadius = 15
//        roundedCornerView.layer.masksToBounds = true
//        roundedCornerView.layer.borderWidth = 0.5
//        roundedCornerView.layer.borderColor =  UIColor.blackColor().CGColor
//        roundedCornerView.backgroundColor = UIColor(red: 241/255, green: 242/255, blue: 243/255, alpha: 1.0)
    }
    
    // ピンチイン・ピンチアウト
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.noBarView
    }
    
    // ダ@objc ブルタップ
    @objc func doubleTap(_ gesture: UITapGestureRecognizer) -> Void {
        
        print(self.myScrollView.zoomScale)
        if ( self.myScrollView.zoomScale < self.myScrollView.maximumZoomScale ) {
            
            let newScale:CGFloat = self.myScrollView.zoomScale * 2
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
