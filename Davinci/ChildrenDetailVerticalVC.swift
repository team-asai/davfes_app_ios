//
//  ChildrenDetailVerticalVC.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/17.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ImageViewer


class ChildrenDetailVerticalVC: UIViewController{

    @IBOutlet weak var planIdImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoImage: UIImageView!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var illustImage: UIImageView!
    // 実施時間
    @IBOutlet weak var onTimeLabel: UILabel!
    // 実施時間の詳細
    @IBOutlet weak var onTimeDetailLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var targetDetailLabel: UILabel!
    @IBOutlet weak var receiveLabel: UILabel!
    // 場所のView
    @IBOutlet weak var roomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noBarView: UIView!
    
    let ud = UserDefaults.standard
    
    var navigationBarHeight: CGFloat!
    var barHeight: CGFloat!
    var displayWidth: CGFloat!
    var displayHeight: CGFloat!
    
    var selectedSectionId:Int!
    var plans: PlanManager!
    
    var delegater: Delegater!
    
    var items: [DataItem] = []
    
    // スクロールビューの初期位置調整のため
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    // Viewが廃棄される前に呼ばれる
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restorationIdentifier = "ChildrenDetailVerticalVC"
        
//        navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
//        barHeight = UIApplication.shared.statusBarFrame.size.height
        navigationBarHeight = 0
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
        
        scrollView.contentInset = UIEdgeInsets(top: -(navigationBarHeight + barHeight), left: 0, bottom: (navigationBarHeight + barHeight), right: 0)
        
        // プランIDの画像
        if(plans.ids[selectedSectionId] < 10){
            planIdImage.image = UIImage(named: "0\(plans.ids[selectedSectionId])")
        }else{
            planIdImage.image = UIImage(named: String(plans.ids[selectedSectionId]))
        }
        
        // タイトルラベル
        print(plans.sections[selectedSectionId])
        titleLabel.text = plans.sections[selectedSectionId]
        titleLabel.font = UIFont.boldSystemFont(ofSize: calc(20.0))
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 2
        
        // いいねイメージ
        if(ud.object(forKey: String(plans.ids[selectedSectionId])) as! Bool == true){
            favoImage.image = UIImage(named: "heart")
        }else if(ud.object(forKey: String(plans.ids[selectedSectionId])) as! Bool == false){
            favoImage.image = UIImage(named: "heart_off")
        }
        favoImage.isUserInteractionEnabled = true
        
        // いいねタップジェスチャーの登録
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ChildrenDetailVerticalVC.tapFavoriteImage(_:)))
        favoImage.addGestureRecognizer(gesture)
        favoImage.tag = selectedSectionId
        
        // 画像
        let pictureUrl = ud.string(forKey: "serverName")! + plans.imgUrls[selectedSectionId]
        Alamofire.request(pictureUrl, method: .get).responseImage { response in
            guard let image = response.result.value else {
                // Handle error
                print("画像が取得できませんでした")
                return
            }
            // Do stuff with your image
            self.imageLabel.image = image
            self.imageLabel.isUserInteractionEnabled = true
        }
        
        let imageViews = [imageLabel]
        
        
        for (_, imageView) in imageViews.enumerated() {
            
            guard let imageView = imageView else { continue }
            var galleryItem: GalleryItem!
            
            galleryItem = GalleryItem.image { $0(self.imageLabel.image) }
            
            items.append(DataItem(imageView: imageView, galleryItem: galleryItem))
        }
        
        // 内容
        contentTextView.text = plans.contents[selectedSectionId]
        contentTextView.font = UIFont.systemFont(ofSize: calc(15.0))

        // イラスト画像
        let illustName = "D\((plans.ids[selectedSectionId] + 1)  % 4 + 1)"
        illustImage.image = UIImage(named: illustName)
        
        // 実施時間
        onTimeLabel.text = "実施時間"
        onTimeLabel.font = UIFont.systemFont(ofSize: calc(17.0))
        
        // 実施時間詳細
        onTimeDetailLabel.text = "\(plans.times[selectedSectionId])"
        onTimeDetailLabel.numberOfLines = 4
        onTimeDetailLabel.font = UIFont.systemFont(ofSize: calc(15.0))
        //onTimeDetailLabel.adjustsFontSizeToFitWidth = true
        
        // 対象
        targetLabel.text = "対象年齢"
        targetLabel.font = UIFont.systemFont(ofSize: calc(17.0))
        
        // 対象詳細
        targetDetailLabel.text = "\(plans.targets[selectedSectionId])"
        targetDetailLabel.font = UIFont.systemFont(ofSize: calc(15.0))
        
        // 申し込み
        receiveLabel.text = plans.reserveInfos[selectedSectionId]
        receiveLabel.font = UIFont.boldSystemFont(ofSize: calc(17.0))
        
        // 場所
        let placeImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0.1*roomView.frame.height, width: 0.8*roomView.frame.height, height: 0.8*roomView.frame.height))
        let placeImgName: String = plans.places[selectedSectionId]
        placeImageView.image = UIImage(named: placeImgName)
        roomView.addSubview(placeImageView)
        
        let floorImageView: UIImageView = UIImageView(frame: CGRect(x: 0.8*roomView.frame.height, y: 0.1*roomView.frame.height, width: 0.8*roomView.frame.height, height: 0.8*roomView.frame.height))
        let floorImgName: String = plans.floors[selectedSectionId]
        floorImageView.image = UIImage(named: floorImgName)
        roomView.addSubview(floorImageView)

        // 2.7*(0.8*roomView.frame.height), : "でお待ちしてます"がはみ出ていたので'2.7'を適当に設定した
        let placeTextLabel: UILabel = UILabel(frame: CGRect(x: 2*(0.8*roomView.frame.height), y: 0.4*roomView.frame.height, width: roomView.frame.width - 2.7*(0.8*roomView.frame.height), height: 0.5*roomView.frame.height))
        placeTextLabel.text = "でお待ちしてます"
        placeTextLabel.font = UIFont.systemFont(ofSize: calc(14.0))
        placeTextLabel.adjustsFontSizeToFitWidth = true
        roomView.addSubview(placeTextLabel)
    }
    
    // 端末サイズに合わせて，大きさを変更してくれる(Widthを基準に大きさ調整)
    func calc(_ val: Double) -> CGFloat{
        var ans: CGFloat!
        ans = (CGFloat(val)/375.0) * displayWidth
        return ans
    }
    
    // いいねイメージタップ時
    @objc func tapFavoriteImage(_ sender: UIGestureRecognizer) {
        print("タップ")

        if(ud.object(forKey: String(plans.ids[(sender.view?.tag)!])) as! Bool == false){
            ud.set(true, forKey: String(plans.ids[(sender.view?.tag)!]))
            self.favoImage.image = UIImage(named: "heart")
            
//            // お気にいり情報をサーバに送信
            FavoListManager.sharedInstance.sendFavoIdList()
        }else if(ud.object(forKey: String(plans.ids[(sender.view?.tag)!])) as! Bool == true){
            ud.set(false, forKey: String(plans.ids[(sender.view?.tag)!]))
            self.favoImage.image = UIImage(named: "heart_off")
            
//            // お気にいり情報をサーバに送信
            FavoListManager.sharedInstance.sendFavoIdList()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /////////////////////// ここから下はImageViewerライブラリのサンプルを改造したもの ///////////////////////
    // もっと最適化できる・・・はず
    @IBAction func showGalleryImageViewer(_ sender: UITapGestureRecognizer) {
        print("hoge")
        guard let displacedView = sender.view as? UIImageView else { return }
        
        guard let displacedViewIndex = items.firstIndex(where: { $0.imageView == displacedView }) else { return }
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: items.count)
        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: items.count)
        
        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: galleryConfiguration())
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            headerView.count = self.items.count
            headerView.currentIndex = index
            footerView.count = self.items.count
            footerView.currentIndex = index
        }
        
        self.presentImageGallery(galleryViewController)
    }
    
    func galleryConfiguration() -> GalleryConfiguration {
        
        return [
            
            GalleryConfigurationItem.closeButtonMode(.builtIn),
            
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            
            // ここをtrueにすることで画面上部のDeleteボタンなどを消すことができる
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(true),
            
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffect.Style.light),
            
            GalleryConfigurationItem.videoControlsColor(.white),
            
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50)
        ]
    }
}

extension ChildrenDetailVerticalVC: GalleryDisplacedViewsDataSource {
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        
        return index < items.count ? items[index].imageView : nil
    }
}

extension ChildrenDetailVerticalVC: GalleryItemsDataSource {
    
    func itemCount() -> Int {
        
        return items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        
        return items[index].galleryItem
    }
}

extension ChildrenDetailVerticalVC: GalleryItemsDelegate {
    
    func removeGalleryItem(at index: Int) {
        //
        print("remove item at \(index)")
        
        let imageView = items[index].imageView
        imageView.removeFromSuperview()
        items.remove(at: index)
    }
}
