//
//  ViewController.swift
//  changeLocalNotification
//
//  Created by Aleksey Kharitonov on 11/05/2019.
//  Copyright © 2019 Aleksey Kharitonov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    
    var granted = false
    let testText = ("mainText", "subText")
    
    // MARK: - Controller's lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationService.shared.userRequest { (granted) in
            granted ? print("granted") : print("denied")
        }

    }
    
    // MARK: - Actions
    
    @IBAction func sendNotification(_ sender: Any) {
        NotificationService.shared.showNotification(with: testText, showBody: false, withAction: true,
                                                   atDate: Date(timeIntervalSinceNow: 1))
    }
}

