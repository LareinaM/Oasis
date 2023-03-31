//
//  EmailRegViewController.swift
//  Oasis
//
//  Created by WU Yifan on 29/10/22.
//

import UIKit
import Firebase

class EmailRegViewController: UIViewController {
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let helper = Helper()
        helper.setUpButtonSimple(button: registerButton, text: "Register", backgroundColor: UIColor.MyTheme.mainpurple, textcolor: .white, cornerRadius: 10.0)
        helper.setNavigation(navigation: self.navigationController)
        
        let gradientLayer = CAGradientLayer.myGradients.lightdirtyfog
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: pwdTextField.text!) { user, error in
            if error != nil{
                print(error as Any)
                
            }
            else{
                print("Register success")
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
