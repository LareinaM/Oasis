//
//  ViewController.swift
//  Oasis
//
//  Created by WU Yifan on 23/9/22.
//

import UIKit
import MapKit
import CoreLocation

extension CLPlacemark {
    var stringValue : String {
        get {
            let lines = (self.addressDictionary?["FormattedAddressLines"] as? [String])!
            let str = lines.joined(separator: ", ")
            print(str)
            return str
        }
    }
}

extension UITextField {
    func isValid(with word: String) -> Bool {
        guard let text = self.text, !text.isEmpty
        else {
            print("Please fill the field.")
            return false
        }
        return true
    }
}

// reverse the geocode location and gives you a CLPlacemark, containing all the informations needed to extract full postal address
extension CLLocation {

    func lookUpPlaceMark(_ handler: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                handler(firstLocation)
            }
            else { handler(nil) }
        }
    }
    
    // gives the full address directly
    func lookUpLocationName(_ handler: @escaping (String?) -> Void) {
            lookUpPlaceMark { (placemark) in
                handler(placemark?.stringValue)
            }
        }
}

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var startLocInput: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locatemeButton: UIButton!
    let maxTextFields = 10
    let buttonOffset : CGFloat = 80.0
    let littleOffset : CGFloat = 16.0
    var textFields: [Int] = []
    let textFieldSize = CGSize(width: 326, height: 50)
    let userInputFont : UIFont = UIFont(name: "Pangolin-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18.0)
    let centeredParagraphStyle = NSMutableParagraphStyle()
    
    func setUpButton(button: UIButton){
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func setUpThings(){
        centeredParagraphStyle.alignment = .center
        
        self.setUpTextField(textField: addressInput, n: 0, currFont: userInputFont, msg: "Search for a location!")
        textFields.append(0)
        setUpATextField(textField: addressInput)
        
        self.setUpTextField(textField: startLocInput, n: 11, currFont: userInputFont, msg: "📍Current Location")
        
        self.setUpButton(button: plusButton)
        plusButton.frame.origin = CGPoint(x: plusButton.frame.origin.x, y: buttonOffset)
        
        self.setUpButton(button: minusButton)
        minusButton.frame.origin = CGPoint(x: minusButton.frame.origin.x, y: buttonOffset)
        
        self.setUpButton(button: locatemeButton)
        self.setUpButton(button: searchButton)
        
    }
    
    func setUpATextField(textField: UITextField) {
        textField.addTarget(self,action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    func setUpTextField(textField : UITextField, n : Int, currFont: UIFont, msg: String){
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        textField.layer.cornerRadius = 10
        textField.textAlignment = .center
        textField.textColor = UIColor.darkGray
        textField.clipsToBounds = true
        textField.tag = n
        textField.font = currFont
        textField.attributedPlaceholder = NSAttributedString(
            string: msg,
            attributes: [
                .font: currFont,
                .paragraphStyle: centeredParagraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            ])
    }
    
    @IBAction func deleteInput(_ sender: Any) {
        let n = textFields.count
        if n > 1 {
            let lastFieldTag = textFields.removeLast()
            let toRemove : UITextField = self.aView.viewWithTag(lastFieldTag)! as! UITextField
            toRemove.removeFromSuperview()
            // adjust plus and minus button
            let y = plusButton.frame.origin.y - littleOffset - textFieldSize.height
            plusButton.frame.origin = CGPoint(x: plusButton.frame.origin.x, y: y)
            minusButton.frame.origin = CGPoint(x: minusButton.frame.origin.x, y: y)
        }
        else {
            /*
            let alert = UIAlertController(title: "🧐", message: "You cannot delete anymore", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK...", style: .default, handler: { UIAlertAction in
                print("ok")
            }))
            present(alert, animated: true, completion: nil)
             */
            ProgressHUD.showError("🧐 You cannot delete anymore", image: nil, interaction: false)
        }
         
    }
    
    @IBAction func addInput(_ sender: Any) {
        if textFields.count < maxTextFields {
            let n = textFields.count
            let y = CGFloat(n) * (textFieldSize.height + littleOffset) + littleOffset
            let textField = UITextField(frame: CGRect(origin: CGPoint(x: littleOffset, y: y), size: textFieldSize))
            self.setUpTextField(textField: textField, n: n, currFont: userInputFont, msg: "Search for another location!")
            setUpATextField(textField: textField)
            self.aView.addSubview(textField)
            textFields.append(n)
            
            // adjust plus button location
            plusButton.frame.origin = CGPoint(x: plusButton.frame.origin.x, y: y + buttonOffset)
            minusButton.frame.origin = CGPoint(x: minusButton.frame.origin.x, y: y + buttonOffset)
            
        }
        else {
            ProgressHUD.showFailed("😱 It is enough for now...")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setUpThings()
    }
    
    lazy var locationManager: CLLocationManager = {
            var manager = CLLocationManager()
            manager.distanceFilter = 10
            manager.desiredAccuracy = kCLLocationAccuracyBest
            return manager
        }()
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateLocationOnMap(to location: CLLocation, with title: String?) {
            let point = MKPointAnnotation()
            point.title = title
            point.coordinate = location.coordinate
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(point)

            let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(viewRegion, animated: true)
        }
    
    // TODO: enter a new storyboard when tap on search
    @IBAction func enterSearch(_ sender: Any) {
    }
    
    // TODO: change view to scroll-able format
    
    // TODO: get user's start location
    
    
    func searchForLocation(to name: String, n: Int){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = name
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response
            else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            let results = response.mapItems
            print("🔖The tag is \(n), we have \(results.count) results...")
            
            for item in results {
                print(item.placemark.title ?? "No location!")
            }
            //return response.mapItems.map({$0.placemark.location})
            
            self.updateLocationOnMap(to: results[0].placemark.location!, with: results[0].placemark.stringValue)
        }
    }
    
    func updatePlaceMark(to address: String) {
        let geoCoder = CLGeocoder()
            // not a location search feature, so for it to work it will need either a valid address, and identifiable location, a city, state or country in the field to have a result
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemark = placemarks?.first,
                    let location = placemark.location
                else { return }
                self.updateLocationOnMap(to: location, with: placemark.stringValue)
            }
        }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard addressInput.isValid(with: "Singapore")
        else {
             print("Please input a valid address ❌")
             return
            }
        print("✅")
        searchForLocation(to: textField.text!, n: textField.tag)
    }
    
    func locationManager(_ manager: CLLocationManager,
                            didUpdateLocations locations: [CLLocation]) {
           guard let location = locations.first
               else { return }
           
           location.lookUpLocationName { (name) in
               self.updateLocationOnMap(to: location, with: name)
           }
       }
    
    @IBAction func currLocation(_ sender: Any) {
        guard let currentLocation = locationManager.location
        else { return }
        
        currentLocation.lookUpLocationName {
            (name) in
            self.updateLocationOnMap(to: currentLocation, with: name)
        }
    }
}

