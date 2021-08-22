//
//  HomeViewController.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 5/21/21.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.register(defaults: ["FirstLogin" : true])
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        print("hopme, ", UserDefaults.standard.bool(forKey: "FirstLogin"))
        if UserDefaults.standard.bool(forKey: "FirstLogin") == false{
            performSegue(withIdentifier: "homeToTimer", sender: nil)
        }
    }

}
