//
//  allExtensions.swift
//  Oasis
//
//  Created by WU Yifan on 7/10/22.
//

import Foundation
import MapKit
import CoreLocation
import Contacts

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
                handler(placemark?.formattedAddress)
            }
        }
}

extension CLPlacemark {
    var stringValue : String {
        get {
            let address = "\(self.subThoroughfare ?? "") \(self.thoroughfare ?? ""), \(self.locality ?? "") \(self.subLocality ?? "") \(self.administrativeArea ?? ""), \(self.postalCode ?? "")"
            return address.replacingOccurrences(of: ", ,", with: ", ")
        }
    }
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else {
            return nil
        }
        let formatter = CNPostalAddressFormatter()
        return "\(formatter.string(from: postalAddress).replacingOccurrences(of: "\n", with: ", "))"
        }
}

extension UITextField {
    func isValid() -> Bool {
        guard let text = self.text, !text.isEmpty
        else {
            return false
        }
        return true
    }
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

class MyPointAnnotation : MKPointAnnotation {
    var markerTintColor: UIColor?
}

class MyMarkerAnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
        displayPriority = MKFeatureDisplayPriority.required
    }
  }
}
