//
//  ViewController.swift
//  Oasis
//
//  Created by WU Yifan on 23/9/22.
//

import UIKit
import MapKit
import CoreLocation
import _Concurrency

extension CLPlacemark {
    var stringValue : String {
        get {
            var address = "\(self.subThoroughfare ?? "") \(self.thoroughfare ?? ""), \(self.locality ?? "") \(self.subLocality ?? "") \(self.administrativeArea ?? ""), \(self.postalCode ?? "")"
            return address
        }
    }
}

extension UITextField {
    func isValid(with word: String) -> Bool {
        guard let text = self.text, !text.isEmpty
        else {
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
    @IBOutlet weak var initialTextField: UITextField!
    @IBOutlet weak var startLocInput: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locatemeButton: UIButton!
    
    let maxTextFields = 10
    let textFieldSize = CGSize(width: 340, height: 50)
    let userInputFont : UIFont = UIFont(name: "Pangolin-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18.0)
    let buttonSize : CGFloat = 55.0
    let buttonOffset : CGFloat = 80.0
    let offsetY : CGFloat = 16.0
    let offsetYFromAbove : CGFloat = 50.0
    let offsetX : CGFloat = 25.0
    let textColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
    let centeredParagraphStyle = NSMutableParagraphStyle()
    
    var textFields: [Int] = []
    
    func setUpButton(button: UIButton){
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func setUpThings(){
        centeredParagraphStyle.alignment = .center
        
        self.setUpTextField(textField: initialTextField, n: 1, currFont: userInputFont, msg: "Search for a location!")
        textFields.append(1)
        setUpATextField(textField: initialTextField)
        
        self.setUpTextField(textField: startLocInput, n: 12, currFont: userInputFont, msg: "📍Current Location")
        
        self.setUpButton(button: plusButton)
        plusButton.frame.origin = CGPoint(x: plusButton.frame.origin.x, y: buttonOffset + offsetYFromAbove)
        
        self.setUpButton(button: minusButton)
        minusButton.frame.origin = CGPoint(x: minusButton.frame.origin.x, y: buttonOffset + offsetYFromAbove)
        
        self.setUpButton(button: locatemeButton)
        self.setUpButton(button: searchButton)
        
    }
    
    func setUpATextField(textField: UITextField) {
        textField.addTarget(self,action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    func setUpTextField(textField : UITextField, n : Int, currFont: UIFont, msg: String){
        textField.backgroundColor = UIColor.white
        textField.textColor = textColor
        textField.layer.cornerRadius = 10
        textField.textAlignment = .center
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
            let y = plusButton.frame.origin.y - offsetY - textFieldSize.height
            plusButton.frame.origin.y = y
            minusButton.frame.origin.y = y
        }
        else {
            ProgressHUD.showError("🧐 You cannot delete anymore", image: nil, interaction: false)
        }
         
    }
    
    @IBAction func addInput(_ sender: Any) {
        if textFields.count < maxTextFields {
            let n = textFields.count
            let y = CGFloat(n) * (textFieldSize.height + offsetY) + offsetYFromAbove
            let textField = UITextField(frame: CGRect(origin: CGPoint(x: offsetX, y: y), size: textFieldSize))
            self.setUpTextField(textField: textField, n: n+1, currFont: userInputFont, msg: "Search for another location!")
            setUpATextField(textField: textField)
            self.aView.addSubview(textField)
            textFields.append(n+1)
            
            // adjust plus button location
            plusButton.frame.origin.y = y + buttonOffset
            minusButton.frame.origin.y = y + buttonOffset
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
    
    // TODO: change view to scroll-able format
    
    // TODO: get user's start location
    
    @IBAction func search(_ sender: Any) {
        Task{
            let within : Double = 500
            var searchTexts = Set<String>()
            for tag in textFields{
                let thisTextField : UITextField = self.view.viewWithTag(tag)! as! UITextField
                if (self.textFieldDidChange(thisTextField) != 0){
                    let currText = thisTextField.text!
                    if !searchTexts.contains(currText.lowercased()){
                        searchTexts.insert(currText.lowercased())
                    }
                    else {
                        ProgressHUD.showError("Please input different places 🥹")
                        return
                    }
                }
            }
            try await self.startSearch(searchTexts: Array(searchTexts), within: within)
        }
    }
    
    func startSearch(searchTexts: [String], within: Double) async throws {
        try await withThrowingTaskGroup(of: [MKPlacemark].self){ group in
            guard let startLocation = locationManager.location
            else {
                ProgressHUD.showError("Please choose a valid start location!")
                return
            }
            for text in searchTexts {
                group.addTask {
                    try await self.searchForLocation(to: text, startFrom: startLocation) }
            }
            var toSearch = [[MKPlacemark]]()  // list of results from each textfield
            for try await searchResult in group {
                toSearch.append(searchResult)
            }
            var finalSearchResult : [Keyy:[Int:[Int]]] = [:]  // dict of results from each textfield
            let n = toSearch.count
            var maxCluster = 0
            var resultKeyy : [Keyy] = [Keyy]()
            for i in 0...n-2{
                let resultsI = toSearch[i]
                for j in i+1...n-1{
                    let resultsJ = toSearch[j]
                    for (iResultIdx, iPlace) in resultsI.enumerated() {
                        if let iCoord = iPlace.location{
                            for (jResultIdx,jPlace) in resultsJ.enumerated() {
                                if let jCoord = jPlace.location{
                                    let distanceInMeters = jCoord.distance(from: iCoord)
                                    if distanceInMeters <= within {
                                        let iKeyy = Keyy(queryIndex: i, resultIndex: iResultIdx)
                                        let jKeyy = Keyy(queryIndex: j, resultIndex: jResultIdx)
                                        (finalSearchResult[iKeyy, default: [:]][j, default: []]).append(jResultIdx)
                                        //(finalSearchResult[jKeyy, default: [:]][i, default: []]).append(iResultIdx)
                                        let iCurrSize = finalSearchResult[iKeyy, default: [:]].count
                                        let jCurrSize = finalSearchResult[jKeyy, default: [:]].count
                                        if iCurrSize > maxCluster{
                                            maxCluster = iCurrSize
                                            resultKeyy = [iKeyy]
                                        }
                                        else if iCurrSize == maxCluster{
                                            resultKeyy.append(iKeyy)
                                        }
                                        /*
                                        if jCurrSize > maxCluster{
                                            maxCluster = jCurrSize
                                            resultKeyy = [jKeyy]
                                        }
                                        else if jCurrSize == maxCluster{
                                            resultKeyy.append(jKeyy)
                                        }
                                         */
                                    }
                                }
                                else{ ProgressHUD.showFailed("Search failed for \(j+1)") }
                            }
                        }
                        else{ ProgressHUD.showFailed("Search failed for \(i+1)") }
                    }
                }
            }
            if maxCluster < n-1{
                print("We cannot satisfy all requirements, but checkout...")
            }
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
    }
    
    // return a list of MKPlacemark
    func searchForLocation(to name: String, startFrom : CLLocation) async throws -> [MKPlacemark] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = name
        let search = MKLocalSearch(request: searchRequest)
        var result = [MKPlacemark]()
        let response = try await search.start()
        let places = response.mapItems.map({$0.placemark})
        //sorted(by: { location.distance(from: $0) < location.distance(from: $1)
        result.append(contentsOf: places)
        return result
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
    
    @objc func textFieldDidChange(_ textField: UITextField) -> Int {
        guard initialTextField.isValid(with: "Singapore")
        else {
             print("Please input a valid address ❌")
             return 0
            }
        return 1
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

