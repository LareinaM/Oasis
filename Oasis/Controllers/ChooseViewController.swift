//
//  ChooseViewController.swift
//  Oasis
//
//  Created by WU Yifan on 29/10/22.
//

import UIKit

class ChooseViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let helper = Helper()
        helper.setUpButtonSimple(button: loginButton, text: "Login", backgroundColor: UIColor.MyTheme.orangepink, textcolor: .white, cornerRadius: 10.0)
        helper.setUpButtonSimple(button: registerButton, text: "Register", backgroundColor: UIColor.MyTheme.bluegreen, textcolor: .white, cornerRadius: 10.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.MyTheme.mainpurple, UIColor.blue]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
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
