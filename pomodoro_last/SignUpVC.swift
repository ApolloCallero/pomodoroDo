//
//  SignUpVC.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 5/21/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
class SignUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.register(defaults: ["FirstLogin" : true])
        if UserDefaults.standard.bool(forKey: "FirstLogin") == false{
            //segue to TimerVC
            performSegue(withIdentifier: "signUpToTimer", sender: nil)
        }
        
        
        
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var allowFriendsSwitch: UISwitch!
    
    
    
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            return
        }
        
        let user = Auth.auth().currentUser
        
        
        let userCollection = Firestore.firestore().collection(user!.email!)
        //save user personal data
        var ref: DocumentReference?
        print(user!.email!)
        let userDocu = Firestore.firestore().collection(user!.email!).document("UserInfo").setData([
            "Email": user!.email,
            "first name": firstNameTextField.text!,
            "last name": lastNameTextField.text!,
            "allow friend to add you by email:": allowFriendsSwitch.isOn
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                UserDefaults.standard.set(false, forKey: "FirstLogin")
                self.performSegue(withIdentifier: "signUpToTimer", sender: nil)
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
