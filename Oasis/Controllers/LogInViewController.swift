//
//  LogInViewController.swift
//  Oasis
//
//  Created by WU Yifan on 28/10/22.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Helper().setUpButtonSimple(button: emailLoginButton, text: "Email")
        Helper().setUpButtonSimple(button: googleLoginButton, text: "Google")
        self.navigationController?.navigationBar.tintColor = UIColor.MyTheme.purple3
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
