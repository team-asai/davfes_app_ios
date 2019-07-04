import Foundation
import UIKit
import Alamofire
import SwiftyJSON

// 処理を移譲されるクラス
class Delegater{
    var delegate: BackActionDelegate?
    var delegaterName: String
    
    init (delegaterName: String){
        self.delegaterName = delegaterName
    }
    
    func BackAction(){
        print("Delegater : BackAction")
        self.delegate?.didBackAction()
    }
}
