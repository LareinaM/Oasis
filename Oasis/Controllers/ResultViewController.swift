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

protocol SecondViewControllerDelegate {
    func secondVCWillDismiss(withTimestamp timestamp: TimeInterval)
}

class MyPointAnnotation : MKPointAnnotation {
    var markerTintColor: UIColor?
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.width)
    }
}

@IBDesignable class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0
    
    var locations:[Int:[Location]]!

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

class ResultViewController : UIViewController, MKMapViewDelegate{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var aView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Setup
    /***************************************************************/
    
    var resultKeyy : [Keyy] = [Keyy]()
    var n : Int = 0
    let currentAnnot = MyPointAnnotation()
    var toSearch = [[MKPlacemark]]()
    var maxCluster : Int = 0
    var finalSearchResult : [Keyy:[Int:[Int]]] = [:]
    var width : CGFloat!
    var height : CGFloat!
    var startLocation : CLLocation!
    var labelWidth = 340      // TODO: dynamic sizing
    var offsetX : CGFloat = 25.0   // TODO: dynamic sizing
    let offsetY : CGFloat = 16.0 // offset between textfields
    var offsetYFromAbove : CGFloat = 20.0 // first textfield offset
    let resultFont : UIFont = UIFont(name: "Pangolin-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18.0)
    let resultFontSmall : UIFont = UIFont(name: "Pangolin-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14.0)
    let paragraphStyle = NSMutableParagraphStyle()
    let colorSwitch = [UIColor.MyTheme.purple2, UIColor.MyTheme.green1,UIColor.MyTheme.pink1,  UIColor.MyTheme.blue1, UIColor.MyTheme.orange, UIColor.MyTheme.red, UIColor.MyTheme.pink2, UIColor.MyTheme.green4, UIColor.MyTheme.blue2, UIColor.MyTheme.green3]
    
    func setUpThings(){
        // set parameters
        self.width = self.view.frame.width
        self.height = self.view.frame.height
        let halfOriginY = self.height/2 - 10
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        // set views
        let halfSizeOverlap = self.height/2 + 10
        self.scrollView.isScrollEnabled = true
        self.scrollView.superview!.isUserInteractionEnabled = true
        self.scrollView.layer.cornerRadius = 10
        self.scrollView.frame = CGRect(x: 0, y: halfOriginY, width: self.width, height: halfSizeOverlap)
        self.scrollView.contentSize = CGSizeMake(self.width, halfSizeOverlap+3)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.width, height: halfSizeOverlap)
        self.aView.frame = CGRect(x: 0, y: 0, width: self.width, height: halfSizeOverlap)
        
        // set buttons
        self.backButton.setTitle("", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.mapView.delegate = self
        setUpThings()
        displayResult()
    }
    
    //MARK: - Back
    /***************************************************************/
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Display results
    /***************************************************************/
    func placeLabel(text: NSMutableAttributedString, count: Int, prevHeight : CGFloat, locations:[Int:[Location]]) -> CGFloat{
        let tap = UITapGestureRecognizer(target: self, action: #selector(labelTap))
        let label = PaddingLabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetYFromAbove + CGFloat(count) * offsetY + prevHeight), size: CGSize(width: labelWidth, height: 30)))
        label.locations = locations
        let labelHeight = text.height(withConstrainedWidth: CGFloat(labelWidth) - label.leftInset - label.rightInset) + label.bottomInset + label.topInset
        let newHeight = label.frame.origin.y + labelHeight + offsetYFromAbove
        if newHeight >= self.aView.frame.height{
            self.aView.frame = CGRect(x: self.aView.frame.origin.x, y: self.aView.frame.origin.y, width: self.aView.frame.width, height: newHeight+5)
            self.scrollView.contentSize = CGSizeMake(self.width, newHeight + 5)
        }
        label.numberOfLines = 0
        label.backgroundColor = UIColor.white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 7
        label.frame.size.height = labelHeight
        label.attributedText = text
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.addGestureRecognizer(tap)
        self.aView.addSubview(label)
        return label.frame.height
    }
    
    
    func displayResult(){
        if maxCluster == 0{
            print("No results!")
        }
        else if maxCluster < n-1 {
            print("We cannot satisfy all requirements, but checkout...")
        }
        else{
            print("Yayy")
        }
        if n > 1{
            var count = 0
            var prevHeight : CGFloat = 0.0
            let attr = [NSAttributedString.Key.font : self.resultFont, NSAttributedString.Key.foregroundColor : UIColor.MyTheme.purple3]
            let attrSmall = [NSAttributedString.Key.font : self.resultFontSmall, NSAttributedString.Key.foregroundColor : UIColor.MyTheme.textColorDark]
            for keyy in resultKeyy{
                let currPlace = toSearch[keyy.queryIndex][keyy.resultIndex]
                var currLines = 1
                var idx = 0
                let neighborDict = finalSearchResult[keyy, default: [:]]
                // set text
                let text = NSMutableAttributedString(string:"\(currPlace.name ?? "")", attributes: attr)
                text.append(NSMutableAttributedString(string:", \(currPlace.stringValue)", attributes: attrSmall))
                var locations : [Int:[Location]] = [idx : [Location(title: currPlace.name ?? "", latitude: (currPlace.location?.coordinate.latitude)!, longitude: (currPlace.location?.coordinate.longitude)!)]]
                for (qIdx, rIdxLs) in neighborDict{
                    idx += 1
                    text.append(NSMutableAttributedString(string:"\n", attributes: attrSmall))
                    for rIdx in rIdxLs{
                        let nextPlace = toSearch[qIdx][rIdx]
                        text.append(NSMutableAttributedString(string:"\n\(nextPlace.name ?? "")", attributes: attr))
                        text.append(NSMutableAttributedString(string:", \(nextPlace.stringValue)", attributes: attrSmall))
                        currLines += 1
                        locations[idx, default: []].append(Location(title: nextPlace.name ?? "", latitude: (nextPlace.location?.coordinate.latitude)!, longitude: (nextPlace.location?.coordinate.longitude)!))
                    }
                }
                // set label
                prevHeight += self.placeLabel(text: text, count: count, prevHeight: prevHeight, locations: locations)
                count += 1
                //print(text.mutableString, "\n")
            }
        }
        else {
            for place in toSearch[0]{
                print(place.stringValue,"\n")
            }
        }
        currentAnnot.markerTintColor = UIColor.MyTheme.purple1
        currentAnnot.title = "Start Here"
        currentAnnot.coordinate = CLLocationCoordinate2D(latitude: startLocation.coordinate.latitude, longitude: startLocation.coordinate.longitude)
        self.mapView.addAnnotation(currentAnnot)
    }
    
    @objc func labelTap(_ gesture: UITapGestureRecognizer){
        let label = gesture.view as! PaddingLabel
        var annotations = [MKAnnotation]()
        var zoomRect = MKMapRect.null
        var coordSet = Set<[Double]>()
        for (idx, locationLs) in label.locations {
            for (i, location) in locationLs.enumerated(){
                let annotation = MyPointAnnotation()
                annotation.markerTintColor = self.colorSwitch[idx]
                annotation.title = location.title
                var lon = location.longitude
                let lat = location.longitude
                if coordSet.contains( [lat, lon] ){
                    lon += 1
                }
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: lon)
                annotations.append(annotation)
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                if (zoomRect.isNull) {
                        zoomRect = pointRect
                    }
                else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
        }
        annotations.append(currentAnnot)
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        mapView.addAnnotations(annotations)
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 70, left: 70, bottom: 70, right: 70), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        }
        else {
            annotationView?.annotation = annotation
        }
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.markerTintColor = annotation.markerTintColor
        }
        return annotationView
    }
}
