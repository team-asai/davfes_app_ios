
//
//  AppDelegate.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/03.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import UIKit
import AWSSNS
import AWSCognito

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let ud = UserDefaults.standard

    // 開発用Arn
    let platformApplicationArnDev = "arn:aws:sns:us-east-1:249774220252:app/APNS_SANDBOX/davinciDev"
    // 製品用Arn
    let platformApplicationArnProd = "arn:aws:sns:us-east-1:249774220252:app/APNS/Davinci"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print("applicationDidFinishLaunching")
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.USEast1,
            identityPoolId: "us-east-1:97f44f1b-43e5-46c1-a043-88449d15d52c")
        
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        
        // バッジ、サウンド、アラートをリモート通知対象として登録する
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories:nil)
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.registerUserNotificationSettings(settings)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("start application")
        let deviceTokenString = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("deviceTokenString: \(deviceTokenString)")
        ud.set(deviceTokenString , forKey: "deviceToken")
    
    

        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = deviceTokenString
        request?.platformApplicationArn = platformApplicationArnProd
        sns.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: {(task: AWSTask!) ->  AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
                print("AWSエラーーーーーーーーーー")
            } else {
                let createEndpointResponse = task.result!
                print("endpointArn: \(String(describing: createEndpointResponse.endpointArn))")

                let subscribeRequest = AWSSNSSubscribeInput()
                subscribeRequest?.topicArn = "arn:aws:sns:us-east-1:249774220252:Davinci2016_Topic";
                subscribeRequest?.endpoint = createEndpointResponse.endpointArn;
                subscribeRequest?.protocols = "Application";
                sns.subscribe(subscribeRequest!)
            }
            return nil
        })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("receive")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("receive1:\(userInfo)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

