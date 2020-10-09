//
//  BHJRouterNavigator.swift
//  BHJ_Library_Router
//
//  Created by 26230197 on 01/25/2019.
//  Copyright (c) 2019 26230197. All rights reserved.
//

import UIKit

/// Navigation Action Mode
///
/// - push: push a viewController in NavigationController
/// - present: present a viewController in NavigationController
/// - share: pop to the viewController already in NavigationController or tabBarController
@objc public enum BHJRouterNavigationMode: Int {
    case push
    case present
    case share
}

/// busMediator内在支持的的导航器
public class BHJRouterNavigator: NSObject {

    /// 一个应用一个统一的navigator
    public static let share = BHJRouterNavigator()
    
    /// 通用的拦截跳转方式
    public var hookRouteBlock: ((_ controller: UIViewController, _ baseViewController: UIViewController?, _ routeMode: BHJRouterNavigationMode) -> Bool)?
    
    /// 在BaseViewController下展示URL对应的Controller
    ///
    /// - Parameters:
    ///   - controller: 当前需要present的Controller
    ///   - baseViewController: 展示的BaseViewController
    ///   - routeMode: 展示的方式
    public func showURL(controller: UIViewController, baseViewController: UIViewController?, routeMode: BHJRouterNavigationMode) {
        switch routeMode {
        case .push:
            push(controller: controller, baseViewController: baseViewController)
        case .share:
            popToShared(controller: controller, baseViewController: baseViewController)
        case .present:
            presented(controller: controller, baseViewController: baseViewController)
        }
    }
    
    // MARK: - 私有方法
    private func push(controller: UIViewController, baseViewController: UIViewController?) {
        guard let baseViewController = baseViewController ?? topmostViewController() else {
            return
        }
        if let baseViewController = baseViewController as? UINavigationController {
            baseViewController.pushViewController(controller, animated: true)
        } else if let baseNavController = baseViewController.navigationController {
            baseNavController.pushViewController(controller, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: controller)
            baseViewController.present(navController, animated: true, completion: nil)
        }
    }
    
    private func popToShared(controller: UIViewController, baseViewController: UIViewController?) {
        guard let rootViewContoller = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        if let rootTabController = rootViewContoller as? UITabBarController {
            let viewControllers = rootTabController.viewControllers ?? []
            var selectIndex = -1
            for (index, tmpController) in viewControllers.enumerated() {
                if let tmpController1 = tmpController as? UINavigationController {
                    if popToShared(controller: controller, inNav: tmpController1) {
                        selectIndex = index
                        break
                    }
                } else {
                    if tmpController == controller {
                        selectIndex = index
                        break
                    }
                }
            }
            
            //选中变化的ViewController
            guard selectIndex != -1, selectIndex != rootTabController.selectedIndex else{
                return
            }
            _ = rootTabController.delegate?.tabBarController?(rootTabController, shouldSelect: rootTabController.viewControllers![selectIndex])
        } else if let rootNavContoller = rootViewContoller as? UINavigationController {
            _ = popToShared(controller: controller, inNav: rootNavContoller)
        } else {
            //当前已经在最上面一层了
            if controller != rootViewContoller {
                let navController = UINavigationController(rootViewController: controller)
                rootViewContoller.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    private func popToShared(controller: UIViewController, inNav navigationController: UINavigationController) -> Bool {
        guard navigationController.viewControllers.count > 0 else {
            return false
        }
        var success = false
        let viewControllers = navigationController.viewControllers.reversed()
        for tmpViewController in viewControllers {
            if let presentedViewController = tmpViewController.presentedViewController {
                if let presentedNavController = presentedViewController as? UINavigationController {
                    if popToShared(controller: controller, inNav: presentedNavController) {
                        navigationController.popToViewController(tmpViewController, animated: false)
                        success = true
                        break
                    }
                } else {
                    if presentedViewController ==  controller{
                        navigationController.popToViewController(tmpViewController, animated: false)
                        success = true
                        break
                    }
                }
            } else {
                if tmpViewController == controller {
                    navigationController.popToViewController(tmpViewController, animated: false)
                    success = true
                    break
                }
            }
        }
        return success
    }
    
    private func presented(controller: UIViewController, baseViewController: UIViewController?) {
        guard let baseViewController = baseViewController ?? topmostViewController() else {
            return
        }
        guard !baseViewController.isKind(of: UITabBarController.self), !baseViewController.isKind(of: UINavigationController.self) else {
            return
        }
        if baseViewController.presentedViewController != nil {
            baseViewController.dismiss(animated: true, completion: nil)
        }
        controller.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        baseViewController.present(controller, animated: true, completion: nil)
    }
    
    private func topmostViewController() -> UIViewController? {
        //rootViewController需要是TabBarController,排除正在显示FirstPage的情况
        guard let rootViewContoller = UIApplication.shared.keyWindow?.rootViewController, (rootViewContoller.isKind(of: UITabBarController.self) || rootViewContoller.isKind(of: UINavigationController.self)) else {
            return nil
        }
        //当前显示哪个tab页
        var rootNavController: UINavigationController?
        if let rootViewContoller = rootViewContoller as? UITabBarController {
            rootNavController = rootViewContoller.selectedViewController as? UINavigationController
        } else if let rootViewContoller = rootViewContoller as? UINavigationController {
            rootNavController = rootViewContoller
        } else {
            return rootViewContoller
        }
        guard rootNavController != nil else {
            return nil
        }
        var navController: UIViewController = rootNavController!
        //遍历navController，找到当前控制器
        while navController.isKind(of: UINavigationController.self) {
            var topViewController = (navController as! UINavigationController).topViewController
            if let topNavController = topViewController as? UINavigationController {
                //顶层是个导航控制器，继续循环
                navController = topNavController
            } else {
                //是否有弹出presentViewControllr
                var presentedViewController = topViewController?.presentedViewController
                while presentedViewController != nil {
                    topViewController = presentedViewController
                    if topViewController!.isKind(of: UINavigationController.self) {
                        break
                    } else {
                        presentedViewController = topViewController?.presentedViewController
                    }
                }
                navController = topViewController!
            }
        }
        return navController
    }
    
}

extension BHJRouterNavigator {
    
    /// 外部不能调用该类别中的方法，仅供PPBusMediator中调用
    internal func hookShowURL(controller: UIViewController, baseViewController: UIViewController?, routeMode: BHJRouterNavigationMode) {
        var success = false
        if let hookRouteBlock = hookRouteBlock {
            success = hookRouteBlock(controller, baseViewController, routeMode)
        }
        if !success {
            showURL(controller: controller, baseViewController: baseViewController, routeMode: routeMode)
        }
    }
    
}
