//
//  LogInViewController.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 5/21/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Firebase.Firestore().settings({ experimentalForceLongPolling: true });
        // Do any additional setup after loading the view.
    }
    


    

    

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // TODO: Validate Text Fields
        
        // Create cleaned versions of the text field
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let user = Auth.auth().currentUser
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if error != nil{
                return
            }
            else{
                
                UserDefaults.standard.set(false, forKey: "FirstLogin")
                self?.performSegue(withIdentifier: "logInToTimer", sender: nil)
            }
        }
  
        
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
