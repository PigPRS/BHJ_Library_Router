//
//  BHJRouter.swift
//  BHJ_Library_Router
//
//  Created by 26230197 on 01/25/2019.
//  Copyright (c) 2019 26230197. All rights reserved.
//

import UIKit

/// 总线控制中心
public class BHJRouter: NSObject {
    
    private static var g_connectorMap: [String: BHJRouterConnectorPtr] = [:]
    
    /// 向总控制中心注册挂接点
    @objc public class func register(connector: BHJRouterConnectorPtr) {
        objc_sync_enter(g_connectorMap)
        let connectorClsStr = String(describing: type(of: connector))
        if g_connectorMap[connectorClsStr] == nil {
            g_connectorMap[connectorClsStr] = connector
        }
        objc_sync_exit(g_connectorMap)
    }
    
    /// 向总控制中心注册挂接点
    @objc public class func register(connectors: [BHJRouterConnectorPtr]) {
        objc_sync_enter(g_connectorMap)
        for connector in connectors {
            let connectorClsStr = String(describing: type(of: connector))
            if g_connectorMap[connectorClsStr] == nil {
                g_connectorMap[connectorClsStr] = connector
            }
        }
        objc_sync_exit(g_connectorMap)
    }
    
    /// 向总控制中心移除挂接点
    @objc public class func remove(connector: BHJRouterConnectorPtr) {
        objc_sync_enter(g_connectorMap)
        let connectorClsStr = String(describing: type(of: connector))
        g_connectorMap.removeValue(forKey: connectorClsStr)
        objc_sync_exit(g_connectorMap)
    }
    
    /// 向总控制中心移除挂所有挂接点
    @objc public class func removeAll() {
        objc_sync_enter(g_connectorMap)
        g_connectorMap.removeAll()
        objc_sync_exit(g_connectorMap)
    }
    
    // MARK: - 页面跳转接口
    /// 判断某个URL能否导航
    @objc public class func canRoute(url: URL) -> Bool {
        guard g_connectorMap.count > 0 else {
            return false
        }
        var success = false
        //遍历connector不能并发
        for connector in g_connectorMap.values.reversed() {
            if connector.canOpen(url: url) {
                success = true
                break
            }
        }
        return success
    }
    
    /// 通过URL直接完成页面跳转OC
    @objc public class func routeOC(url: URL) -> Bool {
        return route(url: url, params: nil, model: .push, callbackAction: nil)
    }
    
    /// 通过URL直接完成页面跳转OC
    @objc public class func routeOC(url: URL, params: [String:Any]) -> Bool {
        return route(url: url, params: params, model: .push, callbackAction: nil)
    }
    
    /// 通过URL直接完成页面跳转
    @objc public class func route(url: URL, params: [String:Any]? = nil, model: BHJRouterNavigationMode = .push, callbackAction: (([String : Any]) -> Void)? = nil) -> Bool {
        guard g_connectorMap.count > 0 else {
            return false
        }
        var success = false
        let userParams = userParametersWith(url: url, params: params)
        for connector in g_connectorMap.values.reversed() {
            guard connector.canOpen(url: url), let returnObj = connector.connectToOpen?(url: url, params: userParams, callbackAction: callbackAction) else {
                continue
            }
            success = true
            if let errorVC = returnObj as? BHJRouterTipController {
                if errorVC.errorType != .notURLSupport {
                    success = false
                    #if DEBUG
                    errorVC.analysisError(url: url, params: userParams, show: true)
                    success = true
                    #endif
                }
            } else if !returnObj.isMember(of: UIViewController.self) {
                BHJRouterNavigator.share.hookShowURL(controller: returnObj, baseViewController: nil, routeMode: model)
            }
            break
        }
        #if DEBUG
        if !success {
            BHJRouterTipController.showError(type: .notFound, url: url, params: userParams)
            return false
        }
        #endif
        return success
    }
    
    /// 通过URL获取viewController实例
    @objc public class func viewControllerFor(url: URL, params: [String:Any]? = nil, callbackAction: (([String : Any]) -> Void)? = nil) -> UIViewController? {
        guard g_connectorMap.count > 0 else {
            return nil
        }
        let userParams = userParametersWith(url: url, params: params)
        for connector in g_connectorMap.values.reversed() {
            guard connector.canOpen(url: url), let returnObj = connector.connectToOpen?(url: url, params: userParams, callbackAction: callbackAction) else {
                continue
            }
            if let errorVC = returnObj as? BHJRouterTipController {
                #if DEBUG
                errorVC.analysisError(url: url, params: userParams, show: true)
                #endif
                return nil
            } else if returnObj.isMember(of: UIViewController.self) {
                break
            } else {
                return returnObj
            }
        }
        #if DEBUG
        BHJRouterTipController.showError(type: .notFound, url: url, params: userParams)
        #endif
        return nil
    }
    
    /// 通过URL执行默认操作
    @objc public class func executeAction(url: URL, params: [String:Any]? = nil, callbackAction: (([String : Any]) -> Void)? = nil) -> Any? {
        guard g_connectorMap.count > 0 else {
            return nil
        }
        var result:Any? = nil
        let userParams = userParametersWith(url: url, params: params)
        for connector in g_connectorMap.values.reversed() {
            guard connector.canOpen(url: url) else {
                continue
            }
            result = connector.executeAction?(url: url, params: userParams, callbackAction: callbackAction)
            break
        }
        return result
    }
    
    /// 从url获取query参数放入到参数列表中
    private class func userParametersWith(url: URL, params: [String:Any]?) -> [String:Any] {
        let pairs = url.query?.components(separatedBy: "&") ?? []
        var userParams = [String: Any]()
        for pair in pairs {
            let kv = pair.components(separatedBy: "=")
            if kv.count == 2 {
                let key = kv.first!
                let value = kv.last!.removingPercentEncoding ?? kv.last!
                userParams[key] = value
            }
        }
        if let params = params {
            userParams = userParams.merging(params, uniquingKeysWith: { $1 })
        }
        return userParams
    }
    
}
