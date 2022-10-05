//
//  ViewController.swift
//  Oasis
//
//  Created by WU Yifan on 23/9/22.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI
import _Concurrency

extension CLPlacemark {
    var stringValue : String {
        get {
            let address = "\(self.subThoroughfare ?? "") \(self.thoroughfare ?? ""), \(self.locality ?? "") \(self.subLocality ?? "") \(self.administrativeArea ?? ""), \(self.postalCode ?? "")"
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
    @IBOutlet weak var deleteButton1: UIButton!
    @IBOutlet weak var initialTextField: UITextField!
    @IBOutlet weak var startLocInput: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var distPicker: UISegmentedControl!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var locatemeButton: UIButton!
    
    //MARK: - Setup
    /***************************************************************/
    
    // TODO: change view to scroll-able format
    
    let maxTextFields = 10
    let textFieldSize = CGSize(width: 340, height: 50) // TODO: dynamic sizing
    let userInputFont : UIFont = UIFont(name: "Pangolin-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18.0)
    let buttonSize : CGFloat = 55.0 // TODO: dynamic sizing
    let buttonOffset : CGFloat = 80.0
    let offsetY : CGFloat = 16.0
    var offsetYFromAbove : CGFloat = 50.0
    var offsetX : CGFloat = 25.0   // TODO: dynamic sizing
    var deleteButtonX : CGFloat = 315.0
    let centeredParagraphStyle = NSMutableParagraphStyle()
    var textFieldCount: Int = 0
    var pickerDataDict : [String:Int] = ["100m": 100, "200m": 200, "300m": 300, "500m": 500, "700m": 700, "1km": 1000, "1.5km": 1500, "2km": 2000]
    var within : Int = 500
    var width : CGFloat!
    var height : CGFloat!
    
    func setUpButton(button: UIButton, n: Int, x: CGFloat,y : CGFloat, buttonWidth: CGFloat, buttonHeight: CGFloat){
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.tag = n
        button.frame = CGRectMake(x, y, buttonWidth, buttonHeight)
    }
    
    func setUpPicker(){
        distPicker.frame.origin.x = offsetX
        var y = self.height / 2 - distPicker.frame.height
        y = y - offsetY - textFieldSize.height / 2
        distPicker.frame.origin.y = y
        distPicker.frame.size.width = textFieldSize.width
        distPicker.selectedSegmentTintColor = UIColor.MyTheme.purple2
        distPicker.tintColor = UIColor.white
        distPicker.backgroundColor = UIColor.white
        distPicker.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        distPicker.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.MyTheme.purple3], for: .normal)
    }
    
    func setUpThings(){
        self.width = self.view.frame.width
        self.height = self.view.frame.height
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        offsetX = (self.width - textFieldSize.width) / 2
        offsetYFromAbove = self.height / 2 + textFieldSize.height / 2 + offsetY - self.aView.frame.origin.y
        deleteButtonX = offsetX + textFieldSize.width - textFieldSize.height
        centeredParagraphStyle.alignment = .center
        
        self.setUpTextField(textField: initialTextField, n: 1, currFont: userInputFont, msg: "Search for a location!")
        textFieldCount += 1
        initialTextField.frame.origin.y = offsetYFromAbove
        self.setUpButton(button: deleteButton1, n: 11, x: deleteButtonX, y: offsetYFromAbove, buttonWidth: textFieldSize.height, buttonHeight: textFieldSize.height)
        deleteButton1.addTarget(self, action: #selector(deleteInputField), for: .touchUpInside)
        
        self.setUpTextField(textField: startLocInput, n: 12, currFont: userInputFont, msg: "📍Current Location")
        startLocInput.frame.origin.y = self.height / 2 - textFieldSize.height / 2
        
        self.setUpButton(button: plusButton, n: 0, x: plusButton.frame.origin.x, y: buttonOffset + offsetYFromAbove, buttonWidth: buttonSize, buttonHeight: buttonSize)
        let twoButtonY = distPicker.frame.origin.y - offsetY * 2 - buttonSize
        self.setUpButton(button: locatemeButton, n: 0, x: offsetX, y: twoButtonY, buttonWidth: buttonSize, buttonHeight: buttonSize)
        self.setUpButton(button: searchButton, n: 0, x: self.width-offsetX-buttonSize, y: twoButtonY, buttonWidth: buttonSize, buttonHeight: buttonSize)
        
        self.setUpPicker()
    }
    
    func setUpTextField(textField : UITextField, n : Int, currFont: UIFont, msg: String){
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.MyTheme.textColor
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
        textField.addTarget(self,action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpThings()
    }
    
    //MARK: - Add/Delete textfields
    /***************************************************************/
    func removeButtonText(buttonTag:Int){
        let textToRemove : UITextField = self.aView.viewWithTag(buttonTag-10)! as! UITextField
        textToRemove.removeFromSuperview()
        let buttonToRemove : UIButton = self.aView.viewWithTag(buttonTag)! as! UIButton
        buttonToRemove.removeFromSuperview()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) -> Int {
        guard initialTextField.isValid(with: "Singapore")
        else {
             print("Please input a valid address ❌")
             return 0
            }
        return 1
    }
    
    func moveButtonText(textTag:Int){
        let textToMove : UITextField = self.aView.viewWithTag(textTag)! as! UITextField
        let buttonToMove : UIButton = self.aView.viewWithTag(textTag+10)! as! UIButton
        let changedY = textFieldSize.height + offsetY
        textToMove.frame.origin.y -= changedY
        textToMove.tag -= 1
        buttonToMove.frame.origin.y -= changedY
        buttonToMove.tag -= 1
    }
    
    @objc func deleteInputField(_ sender: UIButton) {
        let buttonTag = sender.tag
        if buttonTag > 11 || textFieldCount > 1 {
            // remove current
            self.removeButtonText(buttonTag: buttonTag)
            print("textfield with tag \(buttonTag-10) removed")
            // move all fields below
            if buttonTag-10 < textFieldCount {
                for tagToMove in buttonTag-9...textFieldCount{
                    print("move textfield with tag \(tagToMove)")
                    self.moveButtonText(textTag: tagToMove)
                }
            }
            // adjust plus button
            let y = plusButton.frame.origin.y - offsetY - textFieldSize.height
            plusButton.frame.origin.y = y
            textFieldCount -= 1
        }
        else {
            ProgressHUD.showError("🧐 You cannot delete anymore", image: nil, interaction: false)
        }
    }
    
    @IBAction func addInput(_ sender: Any) {
        if textFieldCount < maxTextFields {
            let y = CGFloat(textFieldCount) * (textFieldSize.height + offsetY) + offsetYFromAbove
            let textField = UITextField(frame: CGRect(origin: CGPoint(x: offsetX, y: y), size: textFieldSize))
            self.setUpTextField(textField: textField, n: textFieldCount+1, currFont: userInputFont, msg: "Search for another location!")
            self.aView.addSubview(textField)
            
            let newButton = UIButton(type: .system)
            newButton.frame = CGRectMake(deleteButtonX, y, textFieldSize.height, textFieldSize.height)
            newButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
            newButton.tag = textFieldCount+11
            newButton.addTarget(self, action: #selector(deleteInputField), for: .touchUpInside)
            newButton.tintColor = UIColor.MyTheme.purple2
            self.aView.addSubview(newButton)
            
            // adjust plus button location
            plusButton.frame.origin.y = y + buttonOffset
            textFieldCount += 1
        }
        else {
            ProgressHUD.showFailed("😱 It is enough for now...")
        }
    }

    //MARK: - Locations
    /***************************************************************/
    lazy var locationManager: CLLocationManager = {
            var manager = CLLocationManager()
            manager.distanceFilter = 10
            manager.desiredAccuracy = kCLLocationAccuracyBest
            return manager
        }()
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        ProgressHUD.showError("Location Unavailable")
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
    
    // Update current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first
        else { return }
        
        if location.horizontalAccuracy > 0{
            // locationManager.stopUpdatingLocation()
            print(location.coordinate)
        }
        
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
    
    //MARK: - Search
    /***************************************************************/
    @IBAction func search(_ sender: Any) {
        let distStr = distPicker.titleForSegment(at: distPicker.selectedSegmentIndex)
        within = pickerDataDict[distStr!]!
        print(within)
        Task{
            var searchTexts = Set<String>()
            for tag in 1...textFieldCount{
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
    
    func startSearch(searchTexts: [String], within: Int) async throws {
        try await withThrowingTaskGroup(of: [MKPlacemark].self){ group in
            guard let startLocation = locationManager.location // TODO: get user's start location
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
            if n>1 {
                for i in 0...n-2{
                    let resultsI = toSearch[i]
                    for j in i+1...n-1{
                        let resultsJ = toSearch[j]
                        for (iResultIdx, iPlace) in resultsI.enumerated() {
                            if let iCoord = iPlace.location{
                                for (jResultIdx,jPlace) in resultsJ.enumerated() {
                                    if let jCoord = jPlace.location{
                                        let distanceInMeters = jCoord.distance(from: iCoord)
                                        if distanceInMeters <= Double(within) {
                                            let iKeyy = Keyy(queryIndex: i, resultIndex: iResultIdx)
                                            (finalSearchResult[iKeyy, default: [:]][j, default: []]).append(jResultIdx)
                                            let iCurrSize = finalSearchResult[iKeyy, default: [:]].count
                                            if iCurrSize > maxCluster{
                                                maxCluster = iCurrSize
                                                resultKeyy = [iKeyy]
                                            }
                                            else if iCurrSize == maxCluster{
                                                resultKeyy.append(iKeyy)
                                            }
                                        }
                                    }
                                    else{ ProgressHUD.showFailed("Search failed for \(j+1)") }
                                }
                            }
                            else{ ProgressHUD.showFailed("Search failed for \(i+1)") }
                        }
                    }
                }
            }
            // TODO: show results
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let resultPage = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController{
                self.present(resultPage, animated: true, completion: nil)
                resultPage.resultKeyy = resultKeyy
                resultPage.n = n
                resultPage.toSearch = toSearch
                resultPage.maxCluster = maxCluster
                resultPage.finalSearchResult = finalSearchResult
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
}