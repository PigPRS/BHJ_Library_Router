//
//  ViewController_A.swift
//  PPBusMediatorDemo
//
//  Created by bhj on 2019/1/7.
//  Copyright © 2019 bhj. All rights reserved.
//

import UIKit

class ViewController_A: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    var name = ""
    
    var age = ""
    
    init(name: String, age: String) {
        super.init(nibName: "ViewController_A", bundle: nil)
        self.name = name
        self.age = age
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = name
        self.ageLabel.text = age
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
