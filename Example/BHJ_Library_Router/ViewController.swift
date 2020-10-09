//
//  ViewController.swift
//  BHJ_Library_Router
//
//  Created by 26230197 on 01/25/2019.
//  Copyright (c) 2019 26230197. All rights reserved.
//

import UIKit
import BHJ_Library_Router

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func presentModule_A(_ sender: Any) {
//        BHJRouterNavigator.share.hookRouteBlock = { (_,_,_) in
//            print("123")
//            return true
//        }
        let result = BHJRouter.route(url: URL(string: "productScheme://ADetail?name=prs&age=27")!,
                                     callbackAction: { (params) in
                                        debugPrint("收到回调",params)
        })
        print(result)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

