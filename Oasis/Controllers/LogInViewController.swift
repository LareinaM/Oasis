//
//  LogInViewController.swift
//  Oasis
//
//  Created by WU Yifan on 28/10/22.
//

import UIKit
import Firebase
import GoogleSignIn

class LogInViewController: UIViewController {
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let helper = Helper()
        helper.setUpButtonSimple(button: emailLoginButton, text: "Email", backgroundColor: .white, textcolor: UIColor.MyTheme.textColor, cornerRadius: 10.0)
        helper.setUpButtonSimple(button: googleLoginButton, text: "Google", backgroundColor: .white, textcolor: UIColor.MyTheme.textColor, cornerRadius: 10.0)
        helper.setNavigation(navigation: self.navigationController)
        
        let gradientLayer = CAGradientLayer.myGradients.lightdirtyfog
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                print("Failed! Error = \(error)")
                return
              }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
              else {
                return
              }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Failed, error = \(error)")
                }
                else{
                    print("Login success")
                    self.performSegue(withIdentifier: "goToMain", sender: self)
                }
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
