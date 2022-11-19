//
//  EmailLoginViewController.swift
//  Pods
//
//  Created by WU Yifan on 29/10/22.
//

import UIKit
import Firebase

class EmailLoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let helper = Helper()
        helper.setUpButtonSimple(button: loginButton, text: "Login", backgroundColor: UIColor.MyTheme.purple2, textcolor: .white, cornerRadius: 10.0)
        helper.setNavigation(navigation: self.navigationController)
        
        //emailTextField.color = .white
        //pwdTextField.backgroundColor = .white
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: pwdTextField.text!) { user, error in
            if error != nil{
                print(error as Any)
                
            }
            else{
                print("Login success")
                self.performSegue(withIdentifier: "goToMain", sender: self)
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
