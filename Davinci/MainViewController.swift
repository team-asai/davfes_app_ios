//
//  MainViewController.swift
//  Davinci
//
//  Created by 高松将也 on 2016/07/30.
//  Copyright © 2016年 高松将也. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var deviceToken: UILabel?
    @IBOutlet weak var endpointArn: UILabel?
    @IBOutlet weak var userAction: UILabel?
    
    func displayDeviceInfo() {
        deviceToken?.text = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken") ?? "N/A"
        endpointArn?.text = NSUserDefaults.standardUserDefaults().stringForKey("endpointArn") ?? "N/A"
    }
    
    func displayUserAction(action: NSString?) {
        if action == nil {
            userAction?.text = "---"
        } else {
            userAction?.text = "The user selected [" + (action! as String) + "]"
        }
    }
}