//
//  ResultViewController.swift
//  Oasis
//
//  Created by WU Yifan on 3/10/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SwiftUI

class ResultViewController : UIViewController{
    var resultKeyy : [Keyy] = [Keyy]()
    var n : Int = 0
    var toSearch = [[MKPlacemark]]()
    var maxCluster : Int = 0
    var finalSearchResult : [Keyy:[Int:[Int]]] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayResult()
    }
    
    func displayResult(){
        if maxCluster < n-1 {
            print("We cannot satisfy all requirements, but checkout...")
        }
        else{
            print("Yayy")
        }
        if n > 1{
            for keyy in resultKeyy{
                print(toSearch[keyy.queryIndex][keyy.resultIndex])
                let neighborDict = finalSearchResult[keyy, default: [:]]
                for (qIdx,rIdxLs) in neighborDict{
                    for rIdx in rIdxLs{
                        print(toSearch[qIdx][rIdx])
                    }
                }
                print()
            }
        }
        else {
            for place in toSearch[0]{
                print(place.stringValue,"\n")
            }
        }
    }
}
