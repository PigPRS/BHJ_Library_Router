//
//  Connector_A.swift
//  PPBusMediatorDemo
//
//  Created by bhj on 2019/1/7.
//  Copyright © 2019 bhj. All rights reserved.
//

import UIKit
import BHJ_Library_Router

class Connector_A: NSObject, BHJRouterConnectorPtr {
    
    internal var host: String = "ADetail"
    
    public static let share = Connector_A()
    
    public func canOpen(url: URL) -> Bool {
        return url.host == host
    }
    
    public func connectToOpen(url: URL, params: [String : Any], callbackAction: (([String : Any]) -> Void)?) -> UIViewController? {
        //解析参数
        let name = params["name"] as? String ?? ""
        let age = params["age"] as? String ?? ""
        let vc = ViewController_A(name: name, age: age)
        callbackAction?(["haha":"123"])
        return vc
//        return PPBusTipController.initError(type: .paramsError)
//        return PPBusTipController.initError(type: .notFound)
    }
    
}
