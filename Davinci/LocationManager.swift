//
//  LocationManager.swift
//  Davinci
//
//  Created by 高松将也 on 2016/08/01.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

class LocationManager : CLLocationManager, CLLocationManagerDelegate{
    // インスタンス
    fileprivate static let sharedInstance = LocationManager()
    let model = locationManagerModel()

    var sameMinorCount:Int = 0
    var differentMinorCount:Int = 0
    
    var nowBeacon:BeaconInfo!
    
    // 設定
    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "00000000-6DC8-1001-B000-001C4D88ED46")!, identifier: "settingBeacon")
    
    //var BLManager: BeaconListManager = BeaconListManager()
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        manager.requestState(for: region)
        // 領域観測の開始
        manager.startRangingBeacons(in: beaconRegion)
    }
    
    //
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion) {
                
                beaconRegion.notifyEntryStateOnDisplay = true
                
                manager.startMonitoring(for: beaconRegion)
            }
        }
    }
    
    // ビーコン情報
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        beacons.forEach { (beacon) in
            
            print("major:\(beacon.major)")
            print("minor:\(beacon.minor)")
            
            if(nowBeacon == nil){
                nowBeacon = BeaconInfo(minor: Int(beacon.minor), flag: false)
            }
            
            // 2回目以降，実は6連続検知でPOST
            if(nowBeacon.minor == beacon.minor){
                sameMinorCount += 1
                differentMinorCount = 0
                if(sameMinorCount >= 3 && nowBeacon.flag == false){
                    // post
                    model.noticeVisiting(String(beacon.major), minor: String(beacon.minor))
                    print("Posted!!!")
                    nowBeacon.flag = true
                }
            }else if(nowBeacon.minor != beacon.minor){
                sameMinorCount = 0
                differentMinorCount += 1
                if(differentMinorCount >= 3){
                    nowBeacon = BeaconInfo(minor: Int(beacon.minor), flag: false)
                }
            }
        }
    }
    
    class BeaconInfo{
        var minor: Int!
        var flag: Bool!
        init(minor: Int, flag:Bool){
            self.minor = minor
            self.flag = flag
        }
    }
    
    // ビーコン領域が変わった時
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            print("変わった")
//            BLManager.getBeacon()
//            let num: Int = BLManager.getBeaconNUm()
//            print(num)
        }
    }
    
    // ビーコン領域に入った時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("入った")
        
        // 領域観測の開始
        //manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    // ビーコン領域から出た時
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        print("出た")
    }
    
    /**
     位置情報取得の許可を確認
     */
    static func requestAlwaysAuthorization() {
        
        // バックグラウンドでも位置情報更新をチェックする
        if #available(iOS 9.0, *) {
            sharedInstance.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        sharedInstance.delegate = sharedInstance
        sharedInstance.requestAlwaysAuthorization()
    }
}
