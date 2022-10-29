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
        let helper = Helper()
        helper.setUpButtonSimple(button: emailLoginButton, text: "Email", backgroundColor: .white, textcolor: UIColor.MyTheme.textColor)
        helper.setUpButtonSimple(button: googleLoginButton, text: "Google", backgroundColor: .white, textcolor: UIColor.MyTheme.textColor)
        helper.setNavigation(navigation: self.navigationController)
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
