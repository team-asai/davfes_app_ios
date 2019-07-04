//
//  SampleView.swift
//  Davinci
//
//  Created by FGO on 2017/07/22.
//  Copyright © 2017年 高松将也. All rights reserved.
//

import Foundation
import UIKit
import GestureRecognizerClosures

class SampleView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGesture()
    }
    
    private func setupGesture() {
        
        // 移動
        onPan { pan in
            let move = pan.translation(in: self)
            self.transform = self.transform.translatedBy(x: move.x, y: move.y)
            pan.setTranslation(CGPoint.zero, in: self)
        }
        
        // 拡大/縮小
        onPinch { pinch in
            self.transform = self.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
        
        // 回転
        onRotate { rotate in
            self.transform = self.transform.rotated(by: rotate.rotation)
            rotate.rotation = 0
        }
    }
}
