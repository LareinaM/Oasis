//
//  sharedAttributes.swift
//  Oasis
//
//  Created by WU Yifan on 29/10/22.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor{
    struct MyTheme{
        static var textColor: UIColor{return UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)}
        static var textColorDark: UIColor{return UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)}
        
        static var lightpurple: UIColor{return UIColor(red: 229/255, green: 227/255, blue: 240/255, alpha: 1)}
        static var mainpurple: UIColor{return UIColor(red: 160/255, green: 155/255, blue: 237/255, alpha: 1)}
        static var verypurple: UIColor{return UIColor(red: 92/255, green: 83/255, blue: 223/255, alpha: 1)}
        
        static var bluegreen: UIColor{return UIColor(red: 26/255, green: 161/255, blue: 184/255, alpha: 1)}
        static var lightgreen: UIColor{return UIColor(red: 210/255, green: 223/255, blue: 209/255, alpha: 1)}
        static var green3: UIColor{return UIColor(red: 160/255, green: 218/255, blue: 199/255, alpha: 1)}
        static var green4: UIColor{return UIColor(red: 167/255, green: 255/255, blue: 228/255, alpha: 1)}
        
        static var orangepink: UIColor{return UIColor(red: 227/255, green: 121/255, blue: 130/255, alpha: 1)}
        static var verypink: UIColor{return UIColor(red: 212/255, green: 71/255, blue: 96/255, alpha: 1)}
        static var lightpink: UIColor{return UIColor(red: 255/255, green: 161/255, blue: 207/255, alpha: 1)}
        
        static var darkblue: UIColor{return UIColor(red: 25/255, green: 35/255, blue: 55/255, alpha: 1)}
        static var hueblue: UIColor{return UIColor(red: 162/255, green: 181/255, blue: 219/255, alpha: 1)}
        static var vividblue: UIColor{return UIColor(red: 49/255, green: 225/255, blue: 247/255, alpha: 1)}
        
        static var orange: UIColor{return UIColor(red: 242/255, green: 89/255, blue: 79/255, alpha: 1)}
        static var red: UIColor{return UIColor(red: 255/255, green: 93/255, blue: 93/255, alpha: 1)}
    }
}

extension CAGradientLayer{
    struct myGradients{
        static var lightdirtyfog: CAGradientLayer{
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.MyTheme.lightpurple.cgColor, UIColor.MyTheme.hueblue.cgColor]
            return gradientLayer
        }
    }
}

extension UIFont{
    struct myFonts{
        static var userInputFont : UIFont {return UIFont(name: "Pangolin-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18.0)}
    }
}

class Helper{
    func setUpButtonSimple(button: UIButton, text: String, backgroundColor: UIColor, textcolor: UIColor, cornerRadius: CGFloat){
        button.titleLabel?.font = UIFont.myFonts.userInputFont
        button.layer.cornerRadius = cornerRadius
        button.tintColor = .clear
        let attr = [NSAttributedString.Key.font : UIFont.myFonts.userInputFont, NSAttributedString.Key.foregroundColor : textcolor]
        let text = NSMutableAttributedString(string:"\(text)", attributes: attr)
        button.setAttributedTitle(text, for: .normal)
        button.backgroundColor = backgroundColor
    }
    
    func setNavigation(navigation: UINavigationController?){
        navigation?.navigationBar.tintColor = UIColor.MyTheme.verypurple
        navigation?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.MyTheme.textColor]
    }
}
