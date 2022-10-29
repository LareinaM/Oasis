//
//  ChooseViewController.swift
//  Oasis
//
//  Created by WU Yifan on 29/10/22.
//

import UIKit

class ChooseViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let helper = Helper()
        helper.setUpButtonSimple(button: loginButton, text: "Login", backgroundColor: UIColor.MyTheme.pink0, textcolor: .white)
        helper.setUpButtonSimple(button: registerButton, text: "Register", backgroundColor: UIColor.MyTheme.green1, textcolor: .white)
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
