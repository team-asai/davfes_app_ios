//
//  ModalDelegate.swift
//  Davinci
//
//  Created by FGO on 2017/07/21.
//  Copyright © 2017年 高松将也. All rights reserved.
//

import Foundation

protocol ModalDelegate{
    func modalDidFinished(modalText: String)
    func showModal(Id: Int)
}
