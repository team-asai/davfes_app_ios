//
//  BeaconManager.swift
//  Davinci
//
//  Created by TakamatsuMasaya on 2017/07/22.
//  Copyright © 2017年 高松将也. All rights reserved.
//

import UIKit
import CoreLocation


/**
 ビーコンの受信を受けてNSNotificationをPostするシングルトンクラス
 sharedInstance経由でアクセスする
 */
class BeaconManager: NSObject, CLLocationManagerDelegate {
    
    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var beaconUuids: NSMutableArray!
    var beaconDetails: NSMutableArray!
    
//    var timeCount: Int = 0
    var latestBeacon: CLBeacon!
    
    let UUIDList = [
        "00000000-6dc8-1001-b000-001c4d88ed46"
    ]
    
    private override init(){
        super.init()
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = 1
        let status = CLLocationManager.authorizationStatus()
//        print("CLAuthorizationDtatus: \(status.rawValue)")
        if(status == .notDetermined){
            myLocationManager.requestAlwaysAuthorization()
        }
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
    }
    
    /**
     シングルトンインスタンス
     */
    class var sharedInstance : BeaconManager {
        struct Static {
            static let instance : BeaconManager = BeaconManager()
        }
        return Static.instance
    }
    
    
    /**
     iBeaconの監視を開始する
     */
    func startMyMonitoring() {
//        print("startMyMonitoring")
        
        for i in 0 ..< UUIDList.count {
            let uuid: NSUUID! = NSUUID(uuidString: "\(UUIDList[i].lowercased())")
            let identifierStr: String = "abcde\(i)"
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: identifierStr)
            myBeaconRegion.notifyEntryStateOnDisplay = false
            myBeaconRegion.notifyOnEntry = true
            myBeaconRegion.notifyOnExit = true
            myLocationManager.startMonitoring(for: myBeaconRegion)
        }
    }
    
    /**
     iBeaconのレンジングを再開する
     */
    func resumeRanging() {
//        print("resumeRanging")
        myLocationManager.startMonitoring(for: self.myBeaconRegion)
    }
    
    /**
     iBeaconのレンジングをストップする。
     */
    func stopRanging() {
//        print("stopRanging")
        myLocationManager.stopRangingBeacons(in: self.myBeaconRegion)
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    // region内にすでにいる場合に備えて、必ずregionについての状態を知らせてくれるように要求する必要がある
    // このリクエストは非同期で行われ、結果は locationManager:didDetermineState:forRegion: で呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        print("didStartMonitoring")
        
        manager.requestState(for: region);
    }
    
    // 位置情報を使うためのユーザーへの認証が必要になる
    // 認証を依頼するためにコードでリクエストを出すないといけない
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print("didChangeAuthorizationStatus");
        
        switch (status) {
        case .notDetermined:
//            print("not determined")
            break
        case .restricted:
//            print("restricted")
            break
        case .denied:
//            print("denied")
            break
        case .authorizedAlways:
//            print("authorizedAlways")
            startMyMonitoring()
            break
        case .authorizedWhenInUse:
//            print("authorizedWhenInUse")
            startMyMonitoring()
            break
        @unknown default:
            break
        }
    }
    
    // エラーが通知される
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError")
        print(error)
    }
    
    // iBeaconの範囲内にいるのかいないのかが通知される
    // いる場合はレンジングを開始する。
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("didDetermineState")
        
        switch (state) {
        case .inside:
            print("iBeacon inside");
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break;
        case .outside:
            print("iBeacon outside")
            break;
        case .unknown:
            print("iBeacon unknown")
            break;
        }
    }
    
    // iBeaconの範囲内にいる場合に1秒間隔で呼ばれ、iBeaconの情報を取得できる。
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        print("didRangeBeacons")
        
        // 最前面のViewControllerを取得して、マップ画面だったら処理する
        if let vc  = UIApplication.topViewController()  {
//            print(vc.restorationIdentifier as String?)
            let id = vc.restorationIdentifier as String?
            
            // とりあえずRSSIの近いビーコンを探してからどうぞ。
            if let beacon: CLBeacon = selectNearestBeacon(beacons: beacons) {
                // ついでにサーバにmajor,minorをPOST！
                if latestBeacon != nil {
                    if(latestBeacon.major != beacon.major){
                        if(latestBeacon.minor != beacon.minor){
                            print("さっきまでと違うビーコンを検知したのでPOST")
                            BeaconPlaces.sharedInstance.noticeVisiting(major: String(describing: beacon.major), minor: String(describing: beacon.minor))
                            latestBeacon = beacon
                        }
                    }
                }else{
                    latestBeacon = beacon
                    BeaconPlaces.sharedInstance.noticeVisiting(major: String(describing: beacon.major), minor: String(describing: beacon.minor))
                }
                
                // 最前面の画面がMapVCだった場合
                if(id == "MapVC"){
                    let mapVC: MapVC = vc as! MapVC
                    if let json = BeaconPlaces.sharedInstance.BeaconMatching(beacon: beacon) {
                        print("update location")
                        mapVC.updateLocation(json: json)
                    }
                }
            }
        }
        
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
        if(beacons.count > 0){
            for i in 0 ..< beacons.count {
                let beacon = beacons[i]
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                var proximity = ""
                switch (beacon.proximity) {
                case CLProximity.unknown :
//                    print("Proximity: Unknown");
                    proximity = "Unknown"
                    break
                case CLProximity.far:
//                    print("Proximity: Far");
                    proximity = "Far"
                    break
                case CLProximity.near:
//                    print("Proximity: Near");
                    proximity = "Near"
                    break
                case CLProximity.immediate:
//                    print("Proximity: Immediate");
                    proximity = "Immediate"
                    break
                @unknown default:
                    break
                }
                beaconUuids.add(beaconUUID.uuidString)
                var myBeaconDetails = "Major: \(majorID) "
                myBeaconDetails += "Minor: \(minorID) "
                myBeaconDetails += "Proximity:\(proximity) "
                myBeaconDetails += "RSSI:\(rssi)"
//                print(myBeaconDetails)
                beaconDetails.add(myBeaconDetails)
            }
        }
    }
    
//    複数のbeaconを検知した場合、RSSIが一番小さいものを選択
    func selectNearestBeacon(beacons: [CLBeacon]) -> CLBeacon? {
//        print("selectNearestBeacon")
        var nearestBeacon: CLBeacon? = nil
        var nearestRssi: Int!

        for beacon in beacons{
//            領域外に離れた後、少しの間、rssi = 0としてビーコンを検知してまうので、その対策
            if(beacon.rssi != 0){
                if nearestBeacon != nil{
                    if (abs(nearestRssi) > abs(beacon.rssi)){
                        nearestRssi = beacon.rssi
                        nearestBeacon = beacon
                    }else{
                        // 何もしない
                    }
                }
                else{
//                    print("初期化するからここの処理に入る")
                    nearestRssi = beacon.rssi
                    nearestBeacon = beacon
                }
            }
        }
        return nearestBeacon
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion: iBeacon found");
        
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion: iBeacon lost");
        
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
}

// 最前面のViweControllerを取得するためのエクステンション
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
