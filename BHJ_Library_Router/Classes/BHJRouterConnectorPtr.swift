//
//  BHJRouterConnectorPtr.swift
//  BHJ_Library_Router
//
//  Created by 26230197 on 01/25/2019.
//  Copyright (c) 2019 26230197. All rights reserved.
//

import Foundation
import UIKit

/// 每个业务模块在对外开放的挂接点实现这个协议，以便被BusMediator发现和调度
@objc public protocol BHJRouterConnectorPtr {
    
    /// 当前业务组件标记名
    @objc var host: String { get }
    
    /// 当前业务组件可导航的URL询问判断
    @objc func canOpen(url: URL) -> Bool
    
    /// 业务模块挂接中间件，注册自己能够处理的URL，完成url的跳转；
    /// 如果url跳转需要回传数据，则传入实现了数据接收的调用者；
    ///
    /// - Parameters:
    ///   - url: 跳转到的URL，通常为 productScheme://connector/relativePath
    ///   - params: 伴随url的的调用参数
    ///   - callbackAction: 回调事件
    /// - Returns:
    ///   - (1): UIViewController的派生实例，交给中间件present;
    ///   - (2): nil 表示不能处理;
    ///   - (3): [UIViewController notURLController]的实例，自行处理present;
    ///   - (4): [UIViewController paramsError]的实例，参数错误，无法导航;
    @objc optional func connectToOpen(url: URL, params: [String:Any], callbackAction: (([String:Any]) -> Void)?) -> UIViewController?
    
    /// 当前业务组件执行一些操作
    ///
    /// - Parameters:
    ///   - url: 跳转到的URL
    ///   - params: 伴随url的的调用参数
    ///   - callbackAction: 回调事件
    @objc optional func executeAction(url: URL, params: [String:Any], callbackAction: (([String:Any]) -> Void)?) -> Any?
    
}
