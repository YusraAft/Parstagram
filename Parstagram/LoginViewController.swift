//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Mac User on 3/21/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBAction func onSignIn(_ sender: Any) {
        
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password){(user, error) in
            //either I have a user or nil
            //pfuser type -> user
            if user != nil{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
                //atttempt to sign up if succeeded then perform segue way otherwise do this
                else{
                    print("Error: \(error?.localizedDescription)")
                }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
          // other fields can be set just like with PFObject
        
        user.signUpInBackground { (success, error) in
            //if error != nil //something when wrong
            //can also say
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            //atttempt to sign up if succeeded then perform segue way otherwise do this
            else{
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
