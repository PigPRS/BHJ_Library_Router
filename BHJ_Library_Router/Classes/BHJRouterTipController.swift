//
//  BHJRouterTipController.swift
//  BHJ_Library_Router
//
//  Created by 26230197 on 01/25/2019.
//  Copyright (c) 2019 26230197. All rights reserved.
//

import UIKit

/// BusMediator错误类型
///
/// - unknown: 未知
/// - paramsError: 参数解析错误
/// - notURLSupport: 不需要中间件进行present展示，表示当前可处理
/// - notFound: 未发现中间件
public enum BHJRouterTipErrorType {
    case unknown
    case paramsError
    case notURLSupport
    case notFound
}

/// busMediator内在错误显示控制器
public class BHJRouterTipController: UIViewController {
    
    private lazy var errorLabel: UILabel = { [weak self] in
        let label = UILabel()
        label.center = self!.view.center
        label.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        self!.view.addSubview(label)
        return label
    }()
    
    private lazy var backButton: UIButton = { [weak self] in
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height - 80, width: UIScreen.main.bounds.width * 0.6, height: 44)
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.addTarget(self!, action: #selector(backBtnAction), for: .touchUpInside)
        return btn
    }()
    
    private(set) var errorType: BHJRouterTipErrorType = .unknown
    
    // MARK: - 初始化
    public class func initError(type: BHJRouterTipErrorType) -> BHJRouterTipController {
        let vc = BHJRouterTipController()
        vc.errorType = type
        return vc
    }
    
    public class func showError(type: BHJRouterTipErrorType, url: URL, params: [String:Any]) {
        let vc = BHJRouterTipController.initError(type: type)
        vc.analysisError(url: url, params: params, show: true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(backButton)
    }
    
    // MARK: - 响应事件
    @objc private func backBtnAction() {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            if let parent = self.parent {
                parent.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    public func analysisError(url: URL, params: [String:Any], show: Bool = false) {
        var errorString = ""
        switch errorType {
        case .unknown:
            errorString = "unknown error!!!"
        case .paramsError:
            errorString = "params error!!!"
        case .notURLSupport:
            errorString = "can not support return a url-based controller!!!"
        case .notFound:
            errorString = "can not found url!!!"
        }
        self.errorLabel.text = "open url error: \(errorString)\n\nurlString:\n\t\(url.absoluteString)\n\nparameters:\n\(params.description)"
        if show {
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.dismiss(animated: true) { [weak rootViewController] in
                    rootViewController?.present(self, animated: true, completion: nil)
                }
            } else {
                rootViewController.present(self, animated: true, completion: nil)
            }
        }
    }

}
